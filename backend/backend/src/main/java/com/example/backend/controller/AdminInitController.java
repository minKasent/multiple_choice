package com.example.backend.controller;

import com.example.backend.dto.response.ApiResponse;
import com.example.backend.entity.Role;
import com.example.backend.entity.User;
import com.example.backend.repository.RoleRepository;
import com.example.backend.repository.UserRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

/**
 * Controller để khởi tạo/sửa user admin khi cần thiết
 * CHÚ Ý: Xóa controller này sau khi deploy production
 */
@RestController
@RequestMapping("/admin-init")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Admin Initialization", description = "APIs for admin initialization (Development only)")
public class AdminInitController {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;

    @PostMapping("/recreate-admin")
    @Operation(summary = "Xóa và tạo lại user admin")
    public ResponseEntity<ApiResponse<String>> recreateAdmin() {
        try {
            String adminEmail = "admin@exam.com";
            String adminUsername = "admin";

            // Xóa user admin cũ nếu có
            userRepository.findByEmail(adminEmail).ifPresent(userRepository::delete);
            userRepository.findByUsername(adminUsername).ifPresent(userRepository::delete);

            // Tạo user admin mới
            Role adminRole = roleRepository.findByName("ADMIN")
                    .orElseThrow(() -> new RuntimeException("Admin role not found"));

            User admin = User.builder()
                    .username(adminUsername)
                    .email(adminEmail)
                    .passwordHash(passwordEncoder.encode("Admin@123"))
                    .fullName("System Administrator")
                    .phone("0123456789")
                    .role(adminRole)
                    .provider("local")
                    .isActive(true)
                    .isVerified(true)
                    .build();

            userRepository.save(admin);

            log.info("Admin user recreated successfully: {} / Admin@123", adminEmail);

            return ResponseEntity.ok(
                ApiResponse.success("Admin user recreated successfully. Username: admin, Email: admin@exam.com, Password: Admin@123", null)
            );
        } catch (Exception e) {
            log.error("Error recreating admin user: ", e);
            return ResponseEntity.status(500).body(
                ApiResponse.error("Failed to recreate admin user: " + e.getMessage())
            );
        }
    }

    @GetMapping("/check-admin")
    @Operation(summary = "Kiểm tra user admin có tồn tại không")
    public ResponseEntity<ApiResponse<String>> checkAdmin() {
        String adminEmail = "admin@exam.com";
        String adminUsername = "admin";

        boolean emailExists = userRepository.findByEmail(adminEmail).isPresent();
        boolean usernameExists = userRepository.findByUsername(adminUsername).isPresent();

        String message = String.format(
            "Admin check - Email exists: %s, Username exists: %s",
            emailExists, usernameExists
        );

        if (emailExists || usernameExists) {
            User user = userRepository.findByEmail(adminEmail)
                    .orElse(userRepository.findByUsername(adminUsername).orElse(null));
            if (user != null) {
                message += String.format(
                    " | User details - ID: %d, Active: %s, Verified: %s",
                    user.getId(), user.getIsActive(), user.getIsVerified()
                );
            }
        }

        return ResponseEntity.ok(ApiResponse.success(message, null));
    }
}

