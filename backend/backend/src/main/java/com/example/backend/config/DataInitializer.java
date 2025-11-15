package com.example.backend.config;

import com.example.backend.entity.Role;
import com.example.backend.entity.User;
import com.example.backend.repository.RoleRepository;
import com.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Set;

/**
 * Initialize default data on application startup
 */
@Configuration
@RequiredArgsConstructor
@Slf4j
public class DataInitializer {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    public CommandLineRunner initializeData() {
        return args -> {
            log.info("Initializing default data...");

            // Create default roles
            createRoleIfNotExists("ADMIN");
            createRoleIfNotExists("TEACHER");
            createRoleIfNotExists("PROCTOR");
            createRoleIfNotExists("STUDENT");

            // Create default admin user
            createAdminUserIfNotExists();

            log.info("Data initialization completed");
        };
    }

    private void createRoleIfNotExists(String roleName) {
        if (!roleRepository.findByName(roleName).isPresent()) {
            Role role = Role.builder()
                    .name(roleName)
                    .description("Default " + roleName + " role")
                    .build();
            roleRepository.save(role);
            log.info("Created role: {}", roleName);
        }
    }

    private void createAdminUserIfNotExists() {
        String adminEmail = "admin@exam.com";
        String adminUsername = "admin";

        // Check if admin already exists
        boolean adminExists = userRepository.findByEmail(adminEmail).isPresent()
                || userRepository.findByUsername(adminUsername).isPresent();

        if (!adminExists) {
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
            log.info("Created default admin user: {} / Admin@123", adminEmail);
        } else {
            log.info("Admin user already exists, skipping creation");
        }
    }
}
