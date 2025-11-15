package com.example.backend.mapper;

import com.example.backend.dto.response.RoleResponse;
import com.example.backend.dto.response.UserResponse;
import com.example.backend.entity.User;
import org.springframework.stereotype.Component;

/**
 * Mapper for User entity to DTOs
 */
@Component
public class UserMapper {
    
    public UserResponse toUserResponse(User user) {
        if (user == null) {
            return null;
        }
        
        RoleResponse roleResponse = null;
        if (user.getRole() != null) {
            roleResponse = RoleResponse.builder()
                    .id(user.getRole().getId())
                    .name(user.getRole().getName())
                    .description(user.getRole().getDescription())
                    .build();
        }
        
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .studentCode(user.getStudentCode())
                .teacherCode(user.getTeacherCode())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .role(roleResponse)
                .isActive(user.getIsActive())
                .isVerified(user.getIsVerified())
                .lastLogin(user.getLastLogin())
                .createdAt(user.getCreatedAt())
                .provider(user.getProvider())
                .build();
    }
}

