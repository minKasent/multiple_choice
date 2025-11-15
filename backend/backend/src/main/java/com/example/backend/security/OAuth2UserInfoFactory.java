package com.example.backend.security;

import java.util.Map;

/**
 * Factory for creating OAuth2UserInfo based on provider
 */
public class OAuth2UserInfoFactory {

    public static OAuth2UserInfo getOAuth2UserInfo(String registrationId, Map<String, Object> attributes) {
        if (registrationId.equalsIgnoreCase("google")) {
            return new GoogleOAuth2UserInfo(attributes);
        }
        throw new IllegalArgumentException("Sorry! Login with " + registrationId + " is not supported yet.");
    }
}

