package com.example.backend.service;

import com.example.backend.config.JwtConfig;
import com.example.backend.dto.request.LoginRequest;
import com.example.backend.dto.request.RefreshTokenRequest;
import com.example.backend.dto.request.RegisterRequest;
import com.example.backend.dto.response.AuthResponse;
import com.example.backend.dto.response.UserResponse;
import com.example.backend.entity.RefreshToken;
import com.example.backend.entity.Role;
import com.example.backend.entity.User;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.UnauthorizedException;
import com.example.backend.mapper.UserMapper;
import com.example.backend.repository.RefreshTokenRepository;
import com.example.backend.repository.RoleRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.security.JwtTokenProvider;
import com.example.backend.security.UserDetailsImpl;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import org.springframework.web.client.RestTemplate;
import com.example.backend.dto.request.GoogleSignInRequest;
import com.example.backend.exception.ServerException;

/**
 * Service for handling authentication operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final JwtConfig jwtConfig;
    private final UserMapper userMapper;

    /**
     * Register a new user
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        log.info("Registering new user: {}", request.getUsername());

        // Check if username already exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Check if email already exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Get role (default to STUDENT if not specified)
        String roleName = request.getRole() != null ? request.getRole() : Role.STUDENT;
        Role role = roleRepository.findByName(roleName)
                .orElseGet(() -> roleRepository.findByName(Role.STUDENT)
                        .orElseThrow(() -> new RuntimeException("Default role not found")));

        // Create new user
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .role(role)
                .provider("local")
                .isActive(true)
                .isVerified(false) // Email verification would be implemented later
                .build();

        User savedUser = userRepository.save(user);
        log.info("User registered successfully: {}", savedUser.getUsername());

        // Generate tokens
        UserDetailsImpl userDetails = UserDetailsImpl.build(savedUser);
        String accessToken = jwtTokenProvider.generateAccessToken(userDetails);
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

        // Save refresh token
        saveRefreshToken(savedUser, refreshToken, null);

        UserResponse userResponse = userMapper.toUserResponse(savedUser);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtConfig.getAccessTokenExpiration() / 1000)
                .user(userResponse)
                .build();
    }

    /**
     * Login user
     */
    @Transactional
    public AuthResponse login(LoginRequest request, HttpServletRequest httpRequest) {
        log.info("User login attempt: {}", request.getUsernameOrEmail());

        // Authenticate user
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsernameOrEmail(),
                        request.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();

        // Update last login
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new UnauthorizedException("User not found"));
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(userDetails);
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

        // Save refresh token
        saveRefreshToken(user, refreshToken, httpRequest);

        log.info("User logged in successfully: {}", userDetails.getUsername());

        UserResponse userResponse = userMapper.toUserResponse(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtConfig.getAccessTokenExpiration() / 1000)
                .user(userResponse)
                .build();
    }

    /**
     * Refresh access token
     */
    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        log.info("Refreshing access token");

        String requestRefreshToken = request.getRefreshToken();

        // Validate refresh token
        if (!jwtTokenProvider.validateToken(requestRefreshToken)) {
            throw new UnauthorizedException("Invalid refresh token");
        }

        // Find refresh token in database
        RefreshToken refreshToken = refreshTokenRepository.findByToken(requestRefreshToken)
                .orElseThrow(() -> new UnauthorizedException("Refresh token not found"));

        // Check if token is valid
        if (!refreshToken.isValid()) {
            throw new UnauthorizedException("Refresh token is expired or revoked");
        }

        // Generate new access token
        User user = refreshToken.getUser();
        UserDetailsImpl userDetails = UserDetailsImpl.build(user);
        String newAccessToken = jwtTokenProvider.generateAccessToken(userDetails);

        // Optionally generate new refresh token (refresh token rotation)
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(userDetails);
        
        // Revoke old refresh token
        refreshToken.revoke();
        refreshTokenRepository.save(refreshToken);

        // Save new refresh token
        saveRefreshToken(user, newRefreshToken, null);

        log.info("Access token refreshed successfully for user: {}", user.getUsername());

        UserResponse userResponse = userMapper.toUserResponse(user);

        return AuthResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .tokenType("Bearer")
                .expiresIn(jwtConfig.getAccessTokenExpiration() / 1000)
                .user(userResponse)
                .build();
    }

    /**
     * Logout user
     */
    @Transactional
    public void logout() {
        log.info("User logout");

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()) {
            try {
                UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
                User user = userRepository.findById(userDetails.getId()).orElse(null);
                if (user != null) {
                    // Revoke all refresh tokens for this user
                    refreshTokenRepository.findByUser(user).forEach(token -> {
                        token.revoke();
                        refreshTokenRepository.save(token);
                    });
                    log.info("All refresh tokens revoked for user: {}", user.getEmail());
                }
            } catch (Exception e) {
                log.error("Error during logout", e);
            }
        }
    }

    /**
     * Save refresh token to database
     */
    private void saveRefreshToken(User user, String token, HttpServletRequest request) {
        LocalDateTime expiryDate = LocalDateTime.now()
                .plusSeconds(jwtConfig.getRefreshTokenExpiration() / 1000);

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(token)
                .expiresAt(expiryDate)
                .ipAddress(request != null ? request.getRemoteAddr() : null)
                .userAgent(request != null ? request.getHeader("User-Agent") : null)
                .build();

        refreshTokenRepository.save(refreshToken);
    }

    /**
     * Get current authenticated user
     */
    public UserResponse getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new UnauthorizedException("User is not authenticated");
        }

        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new UnauthorizedException("User not found"));

        return userMapper.toUserResponse(user);
    }

    /**
     * Google Sign In
     */
    @Transactional
    public AuthResponse googleSignIn(GoogleSignInRequest request) {
        log.info("Google sign in attempt");

        try {
            // Verify Google access token and get user info
            String accessToken = request.getAccessToken();
            
            // Call Google UserInfo API to get user details
            RestTemplate restTemplate = new RestTemplate();
            String userInfoUrl = "https://www.googleapis.com/oauth2/v3/userinfo?access_token=" + accessToken;
            
            Map<String, Object> userInfo;
            try {
                @SuppressWarnings("unchecked")
                Map<String, Object> response = restTemplate.getForObject(userInfoUrl, Map.class);
                userInfo = response;
            } catch (Exception e) {
                log.error("Failed to get user info from Google", e);
                throw new BadRequestException("Invalid Google access token");
            }

            if (userInfo == null) {
                throw new BadRequestException("Failed to get user info from Google");
            }

            String email = (String) userInfo.get("email");
            String name = (String) userInfo.get("name");
            String googleId = (String) userInfo.get("sub");
            String picture = (String) userInfo.get("picture");

            if (email == null) {
                throw new BadRequestException("Email not found from Google");
            }

            // Check if user exists
            User user;
            Optional<User> existingUser = userRepository.findByEmail(email);

            if (existingUser.isPresent()) {
                user = existingUser.get();
                
                // Update if provider changed or user info changed
                if (!"google".equals(user.getProvider())) {
                    throw new BadRequestException(
                        "This email is already registered with " + user.getProvider() + ". Please use " + user.getProvider() + " to login."
                    );
                }
                
                // Update user info
                user.setFullName(name);
                user.setProviderId(googleId);
                user.setAvatarUrl(picture);
                user = userRepository.save(user);
                
                log.info("Existing Google user logged in: {}", email);
            } else {
                // Create new user
                Role studentRole = roleRepository.findByName("STUDENT")
                        .orElseThrow(() -> new RuntimeException("Student role not found"));

                // Generate unique username from email
                String baseUsername = email.split("@")[0];
                String username = baseUsername;
                int counter = 1;
                while (userRepository.existsByUsername(username)) {
                    username = baseUsername + counter;
                    counter++;
                }

                user = User.builder()
                        .username(username)
                        .email(email)
                        .passwordHash(passwordEncoder.encode(java.util.UUID.randomUUID().toString())) // Random password for OAuth users
                        .fullName(name)
                        .provider("google")
                        .providerId(googleId)
                        .avatarUrl(picture)
                        .role(studentRole)
                        .isActive(true)
                        .isVerified(true) // Google users are pre-verified
                        .build();

                user = userRepository.save(user);
                log.info("New Google user registered: {}", email);
            }

            // Generate tokens
            UserDetailsImpl userDetails = UserDetailsImpl.build(user);
            String jwtAccessToken = jwtTokenProvider.generateAccessToken(userDetails);
            String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);

            // Save refresh token
            saveRefreshToken(user, refreshToken, null);

            UserResponse userResponse = userMapper.toUserResponse(user);

            return AuthResponse.builder()
                    .accessToken(jwtAccessToken)
                    .refreshToken(refreshToken)
                    .tokenType("Bearer")
                    .expiresIn(jwtConfig.getAccessTokenExpiration() / 1000)
                    .user(userResponse)
                    .build();

        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            log.error("Google sign in failed", e);
            throw new ServerException("Google sign in failed: " + e.getMessage());
        }
    }
}
