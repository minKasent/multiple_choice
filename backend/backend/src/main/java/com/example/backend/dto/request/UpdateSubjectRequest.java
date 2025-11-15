package com.example.backend.dto.request;

import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Update subject request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateSubjectRequest {
    
    @Size(max = 255, message = "Subject name must not exceed 255 characters")
    private String name;
    
    private String description;
    
    private Integer creditHours;
    
    private Boolean isActive;
}

