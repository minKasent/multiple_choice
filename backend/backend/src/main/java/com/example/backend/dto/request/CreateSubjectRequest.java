package com.example.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Create subject request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateSubjectRequest {
    
    @NotBlank(message = "Subject code is required")
    @Size(max = 50, message = "Subject code must not exceed 50 characters")
    private String code;
    
    @NotBlank(message = "Subject name is required")
    @Size(max = 255, message = "Subject name must not exceed 255 characters")
    private String name;
    
    private String description;
    
    private Integer creditHours;
}

