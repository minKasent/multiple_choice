package com.example.backend.dto.request;

import jakarta.validation.constraints.Email;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Update user request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRequest {
    
    private String fullName;
    
    @Email(message = "Email should be valid")
    private String email;
    
    private String phone;
    
    private String avatarUrl;
    
    private String studentCode;
    
    private String teacherCode;
}

