package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

/**
 * Entity representing users in the system
 * Supports multiple roles: ADMIN, TEACHER, PROCTOR, STUDENT
 */
@Entity
@Table(name = "users", indexes = {
        @Index(name = "idx_users_email", columnList = "email"),
        @Index(name = "idx_users_username", columnList = "username"),
        @Index(name = "idx_users_role", columnList = "role_id"),
        @Index(name = "idx_users_is_active", columnList = "is_active")
})
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class User extends BaseEntity {

    @Column(name = "username", unique = true, nullable = false, length = 100)
    private String username;

    @Column(name = "email", unique = true, nullable = false)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    @Column(name = "full_name", nullable = false)
    private String fullName;

    @Column(name = "student_code", unique = true, length = 50)
    private String studentCode;

    @Column(name = "teacher_code", unique = true, length = 50)
    private String teacherCode;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "avatar_url", columnDefinition = "TEXT")
    private String avatarUrl;

    @Column(name = "is_verified")
    private Boolean isVerified = false;

    @Column(name = "last_login")
    private LocalDateTime lastLogin;

    @Column(name = "provider")
    private String provider; // "local", "google", etc.

    @Column(name = "provider_id")
    private String providerId; // OAuth2 provider user ID

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    /**
     * Check if user has specific role
     */
    public boolean hasRole(String roleName) {
        return this.role != null && this.role.getName().equals(roleName);
    }

    /**
     * Check if user is admin
     */
    public boolean isAdmin() {
        return hasRole(Role.ADMIN);
    }

    /**
     * Check if user is teacher
     */
    public boolean isTeacher() {
        return hasRole(Role.TEACHER);
    }

    /**
     * Check if user is proctor
     */
    public boolean isProctor() {
        return hasRole(Role.PROCTOR);
    }

    /**
     * Check if user is student
     */
    public boolean isStudent() {
        return hasRole(Role.STUDENT);
    }
}

