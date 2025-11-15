package com.example.backend.repository;

import com.example.backend.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for User entity
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    /**
     * Find user by username
     */
    Optional<User> findByUsername(String username);
    
    /**
     * Find user by email
     */
    Optional<User> findByEmail(String email);
    
    /**
     * Find user by username or email
     */
    Optional<User> findByUsernameOrEmail(String username, String email);
    
    /**
     * Find user by student code
     */
    Optional<User> findByStudentCode(String studentCode);
    
    /**
     * Find user by teacher code
     */
    Optional<User> findByTeacherCode(String teacherCode);
    
    /**
     * Check if username exists
     */
    boolean existsByUsername(String username);
    
    /**
     * Check if email exists
     */
    boolean existsByEmail(String email);
    
    /**
     * Check if student code exists
     */
    boolean existsByStudentCode(String studentCode);
    
    /**
     * Check if teacher code exists
     */
    boolean existsByTeacherCode(String teacherCode);
    
    /**
     * Find all users by role name
     */
    @Query("SELECT u FROM User u WHERE u.role.name = :roleName AND u.isActive = true")
    List<User> findByRoleName(@Param("roleName") String roleName);
    
    /**
     * Find all users by role name with pagination
     */
    @Query("SELECT u FROM User u WHERE u.role.name = :roleName AND u.isActive = true")
    Page<User> findByRoleName(@Param("roleName") String roleName, Pageable pageable);
    
    /**
     * Find all active users
     */
    List<User> findByIsActive(Boolean isActive);
    
    /**
     * Find all active users with pagination
     */
    Page<User> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * Search users by keyword (username, email, full name)
     */
    @Query("SELECT u FROM User u WHERE u.isActive = true AND " +
           "(LOWER(u.username) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<User> searchUsers(@Param("keyword") String keyword, Pageable pageable);
}

