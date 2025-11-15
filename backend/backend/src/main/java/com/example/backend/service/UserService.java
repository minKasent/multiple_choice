package com.example.backend.service;

import com.example.backend.dto.request.ChangePasswordRequest;
import com.example.backend.dto.request.CreateUserRequest;
import com.example.backend.dto.request.UpdateUserRequest;
import com.example.backend.dto.response.UserResponse;
import com.example.backend.entity.Role;
import com.example.backend.entity.User;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ForbiddenException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.mapper.UserMapper;
import com.example.backend.repository.RoleRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Service for user management operations
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserMapper userMapper;

    /**
     * Get all users with pagination
     */
    public Page<UserResponse> getAllUsers(Pageable pageable) {
        return userRepository.findAll(pageable)
                .map(userMapper::toUserResponse);
    }

    /**
     * Get users by role
     */
    public Page<UserResponse> getUsersByRole(String roleName, Pageable pageable) {
        return userRepository.findByRoleName(roleName, pageable)
                .map(userMapper::toUserResponse);
    }

    /**
     * Search users by keyword
     */
    public Page<UserResponse> searchUsers(String keyword, Pageable pageable) {
        return userRepository.searchUsers(keyword, pageable)
                .map(userMapper::toUserResponse);
    }

    /**
     * Get user by ID
     */
    public UserResponse getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
        return userMapper.toUserResponse(user);
    }

    /**
     * Create new user (admin can create any role, teacher can only create STUDENT)
     */
    @Transactional
    public UserResponse createUser(CreateUserRequest request) {
        log.info("Creating new user: {}", request.getUsername());

        // Check permissions: Teacher can only create STUDENT
        User currentUser = getCurrentUser();
        if (currentUser.getRole().getName().equals("TEACHER") && 
            !request.getRole().equals("STUDENT")) {
            throw new ForbiddenException("Teachers can only create STUDENT users");
        }

        // Check if username exists
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Username is already taken");
        }

        // Check if email exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already in use");
        }

        // Check student code if provided
        if (request.getStudentCode() != null && 
            userRepository.existsByStudentCode(request.getStudentCode())) {
            throw new BadRequestException("Student code is already in use");
        }

        // Check teacher code if provided
        if (request.getTeacherCode() != null && 
            userRepository.existsByTeacherCode(request.getTeacherCode())) {
            throw new BadRequestException("Teacher code is already in use");
        }

        // Get role
        Role role = roleRepository.findByName(request.getRole())
                .orElseThrow(() -> new BadRequestException("Role not found: " + request.getRole()));

        // Create user
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName())
                .phone(request.getPhone())
                .studentCode(request.getStudentCode())
                .teacherCode(request.getTeacherCode())
                .role(role)
                .provider("local")
                .isActive(request.getIsActive())
                .isVerified(request.getIsVerified())
                .createdBy(getCurrentUser())
                .build();

        User savedUser = userRepository.save(user);
        log.info("User created successfully: {}", savedUser.getUsername());

        return userMapper.toUserResponse(savedUser);
    }

    /**
     * Update user profile
     */
    @Transactional
    public UserResponse updateUser(Long id, UpdateUserRequest request) {
        log.info("Updating user: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        // Check if current user can update this user
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin() && !currentUser.getId().equals(id)) {
            throw new ForbiddenException("You don't have permission to update this user");
        }

        // Update fields if provided
        if (request.getFullName() != null) {
            user.setFullName(request.getFullName());
        }

        if (request.getEmail() != null && !request.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmail(request.getEmail())) {
                throw new BadRequestException("Email is already in use");
            }
            user.setEmail(request.getEmail());
        }

        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }

        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }

        // Only admin can update codes
        if (currentUser.isAdmin()) {
            if (request.getStudentCode() != null) {
                user.setStudentCode(request.getStudentCode());
            }
            if (request.getTeacherCode() != null) {
                user.setTeacherCode(request.getTeacherCode());
            }
        }

        user.setUpdatedBy(currentUser);
        User updatedUser = userRepository.save(user);
        
        log.info("User updated successfully: {}", updatedUser.getId());
        return userMapper.toUserResponse(updatedUser);
    }

    /**
     * Change password
     */
    @Transactional
    public void changePassword(Long id, ChangePasswordRequest request) {
        log.info("Changing password for user: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        // Check if current user can change this password
        User currentUser = getCurrentUser();
        if (!currentUser.getId().equals(id)) {
            throw new ForbiddenException("You can only change your own password");
        }

        // Check if user has a password (not OAuth2)
        if (user.getPasswordHash() == null || user.getPasswordHash().isEmpty()) {
            throw new BadRequestException("Cannot change password for OAuth2 users");
        }

        // Verify current password
        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPasswordHash())) {
            throw new BadRequestException("Mật khẩu hiện tại không đúng");
        }

        // Verify new password matches confirm password
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new BadRequestException("New password and confirm password do not match");
        }

        // Update password
        user.setPasswordHash(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        log.info("Password changed successfully for user: {}", id);
    }

    /**
     * Delete user (soft delete)
     */
    @Transactional
    public void deleteUser(Long id) {
        log.info("Deleting user: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        // Prevent deleting self
        User currentUser = getCurrentUser();
        if (currentUser.getId().equals(id)) {
            throw new BadRequestException("You cannot delete your own account");
        }

        // Soft delete
        user.setIsActive(false);
        user.setUpdatedBy(currentUser);
        userRepository.save(user);

        log.info("User deleted successfully: {}", id);
    }

    /**
     * Activate/Deactivate user
     */
    @Transactional
    public void toggleUserStatus(Long id) {
        log.info("Toggling user status: {}", id);

        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        user.setIsActive(!user.getIsActive());
        user.setUpdatedBy(getCurrentUser());
        userRepository.save(user);

        log.info("User status toggled: {} -> {}", id, user.getIsActive());
    }

    /**
     * Get current authenticated user
     */
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Current user not found"));
    }

    /**
     * Get current authenticated user profile
     */
    public UserResponse getCurrentUserProfile() {
        User user = getCurrentUser();
        return userMapper.toUserResponse(user);
    }
}
