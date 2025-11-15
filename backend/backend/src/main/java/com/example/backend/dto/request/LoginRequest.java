package com.example.backend.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Login request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LoginRequest {
    
    @NotBlank(message = "Username or email is required")
    @JsonProperty("usernameOrEmail")
    @JsonAlias({"username", "email", "userName", "userEmail"})
    private String usernameOrEmail;
    
    @NotBlank(message = "Password is required")
    private String password;
}
