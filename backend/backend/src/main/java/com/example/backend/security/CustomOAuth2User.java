package com.example.backend.security;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;

import java.util.Collection;
import java.util.Map;

/**
 * Custom OAuth2User implementation
 */
@Getter
public class CustomOAuth2User implements OAuth2User {
    
    private final OAuth2User oauth2User;
    private final UserDetailsImpl userDetails;

    public CustomOAuth2User(OAuth2User oauth2User, UserDetailsImpl userDetails) {
        this.oauth2User = oauth2User;
        this.userDetails = userDetails;
    }

    @Override
    public Map<String, Object> getAttributes() {
        return oauth2User.getAttributes();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return userDetails.getAuthorities();
    }

    @Override
    public String getName() {
        return userDetails.getUsername();
    }

    public Long getUserId() {
        return userDetails.getId();
    }

    public String getEmail() {
        return userDetails.getEmail();
    }
}

