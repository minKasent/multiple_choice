package com.example.backend.enums;

/**
 * Enum representing difficulty levels of questions
 */
public enum DifficultyLevel {
    /**
     * Easy level
     */
    EASY,
    
    /**
     * Medium level
     */
    MEDIUM,
    
    /**
     * Hard level
     */
    HARD;
    
    /**
     * Get display name for the difficulty level
     */
    public String getDisplayName() {
        return switch (this) {
            case EASY -> "Dễ";
            case MEDIUM -> "Trung bình";
            case HARD -> "Khó";
        };
    }
}

