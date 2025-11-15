package com.example.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Google Sign In Request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GoogleSignInRequest {

    @NotBlank(message = "Access token is required")
    private String accessToken;
}

