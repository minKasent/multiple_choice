package com.example.backend.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

/**
 * CORS Configuration
 */
@Configuration
@ConfigurationProperties(prefix = "app.cors")
@Data
public class CorsConfig {

    private List<String> allowedOrigins;
    private List<String> allowedMethods;
    private List<String> allowedHeaders;
    private List<String> exposedHeaders;
    private Boolean allowCredentials;
    private Long maxAge;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Set allowed origins
        if (allowedOrigins != null && !allowedOrigins.isEmpty()) {
            configuration.setAllowedOrigins(allowedOrigins);
        } else {
            configuration.setAllowedOrigins(Arrays.asList("http://localhost:3000", "http://localhost:5173"));
        }
        
        // Set allowed methods
        if (allowedMethods != null && !allowedMethods.isEmpty()) {
            configuration.setAllowedMethods(allowedMethods);
        } else {
            configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        }
        
        // Set allowed headers
        if (allowedHeaders != null && !allowedHeaders.isEmpty()) {
            configuration.setAllowedHeaders(allowedHeaders);
        } else {
            configuration.setAllowedHeaders(Arrays.asList("*"));
        }
        
        // Set exposed headers
        if (exposedHeaders != null && !exposedHeaders.isEmpty()) {
            configuration.setExposedHeaders(exposedHeaders);
        } else {
            configuration.setExposedHeaders(Arrays.asList("Authorization", "Content-Type"));
        }
        
        // Set allow credentials
        configuration.setAllowCredentials(allowCredentials != null ? allowCredentials : true);
        
        // Set max age
        configuration.setMaxAge(maxAge != null ? maxAge : 3600L);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }
}

