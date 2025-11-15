package com.example.backend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * JWT Configuration Properties
 */
@Configuration
@ConfigurationProperties(prefix = "app.jwt")
@Data
public class JwtConfig {
    
    /**
     * Secret key for JWT signing (minimum 256 bits required)
     */
    private String secret;
    
    /**
     * Access token expiration time in milliseconds (default: 15 minutes)
     */
    private Long accessTokenExpiration = 900000L;
    
    /**
     * Refresh token expiration time in milliseconds (default: 7 days)
     */
    private Long refreshTokenExpiration = 604800000L;
    
    /**
     * Token type prefix (default: Bearer)
     */
    private String tokenPrefix = "Bearer ";
    
    /**
     * Authorization header name
     */
    private String headerName = "Authorization";
}

