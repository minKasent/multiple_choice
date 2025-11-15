package com.example.backend.security;

import com.example.backend.entity.Role;
import com.example.backend.entity.User;
import com.example.backend.repository.RoleRepository;
import com.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Optional;

/**
 * Custom OAuth2 User Service
 * Handles OAuth2 authentication and user registration
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    @Transactional
    public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
        OAuth2User oauth2User = super.loadUser(userRequest);

        try {
            return processOAuth2User(userRequest, oauth2User);
        } catch (Exception ex) {
            log.error("Error processing OAuth2 user", ex);
            throw new OAuth2AuthenticationException(ex.getMessage());
        }
    }

    private OAuth2User processOAuth2User(OAuth2UserRequest userRequest, OAuth2User oauth2User) {
        String registrationId = userRequest.getClientRegistration().getRegistrationId();
        OAuth2UserInfo oauth2UserInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(
                registrationId, 
                oauth2User.getAttributes()
        );

        if (!StringUtils.hasText(oauth2UserInfo.getEmail())) {
            throw new OAuth2AuthenticationException("Email not found from OAuth2 provider");
        }

        Optional<User> userOptional = userRepository.findByEmail(oauth2UserInfo.getEmail());
        User user;

        if (userOptional.isPresent()) {
            user = userOptional.get();
            // Update user if needed
            if (!user.getProvider().equals(registrationId)) {
                throw new OAuth2AuthenticationException(
                    "Looks like you're signed up with " + user.getProvider() + 
                    " account. Please use your " + user.getProvider() + " account to login."
                );
            }
            user = updateExistingUser(user, oauth2UserInfo);
        } else {
            user = registerNewUser(registrationId, oauth2UserInfo);
        }

        UserDetailsImpl userDetails = UserDetailsImpl.build(user);
        return new CustomOAuth2User(oauth2User, userDetails);
    }

    private User registerNewUser(String registrationId, OAuth2UserInfo oauth2UserInfo) {
        // Get student role by default for new OAuth2 users
        Role studentRole = roleRepository.findByName(Role.STUDENT)
                .orElseThrow(() -> new RuntimeException("Student role not found"));

        User user = User.builder()
                .username(generateUsername(oauth2UserInfo.getEmail()))
                .email(oauth2UserInfo.getEmail())
                .fullName(oauth2UserInfo.getName())
                .avatarUrl(oauth2UserInfo.getImageUrl())
                .provider(registrationId)
                .providerId(oauth2UserInfo.getId())
                .role(studentRole)
                .isActive(true)
                .isVerified(true) // OAuth2 users are pre-verified
                .passwordHash("") // No password for OAuth2 users
                .lastLogin(LocalDateTime.now())
                .build();

        User savedUser = userRepository.save(user);
        log.info("New user registered via {}: {}", registrationId, savedUser.getEmail());
        
        return savedUser;
    }

    private User updateExistingUser(User existingUser, OAuth2UserInfo oauth2UserInfo) {
        existingUser.setFullName(oauth2UserInfo.getName());
        existingUser.setAvatarUrl(oauth2UserInfo.getImageUrl());
        existingUser.setLastLogin(LocalDateTime.now());
        
        User updatedUser = userRepository.save(existingUser);
        log.info("Updated existing user: {}", updatedUser.getEmail());
        
        return updatedUser;
    }

    private String generateUsername(String email) {
        String username = email.split("@")[0];
        
        // Check if username already exists
        if (userRepository.existsByUsername(username)) {
            // Append random suffix
            username = username + "_" + System.currentTimeMillis();
        }
        
        return username;
    }
}

