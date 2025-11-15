package com.example.backend.enums;

/**
 * Enum representing different types of questions
 */
public enum QuestionType {
    /**
     * Multiple choice question with multiple answer options
     */
    MULTIPLE_CHOICE,
    
    /**
     * Fill in the blank question
     */
    FILL_IN_BLANK,
    
    /**
     * True/False question
     */
    TRUE_FALSE;
    
    /**
     * Get display name for the question type
     */
    public String getDisplayName() {
        return switch (this) {
            case MULTIPLE_CHOICE -> "Trắc nghiệm";
            case FILL_IN_BLANK -> "Điền khuyết";
            case TRUE_FALSE -> "Đúng/Sai";
        };
    }
}

