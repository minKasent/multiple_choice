package com.example.backend.enums;

/**
 * Enum representing different types of exams
 */
public enum ExamType {
    /**
     * Regular exam
     */
    REGULAR,
    
    /**
     * Midterm exam
     */
    MIDTERM,
    
    /**
     * Final exam
     */
    FINAL,
    
    /**
     * Quiz
     */
    QUIZ,
    
    /**
     * Practice exam
     */
    PRACTICE;
    
    /**
     * Get display name for the exam type
     */
    public String getDisplayName() {
        return switch (this) {
            case REGULAR -> "Thường xuyên";
            case MIDTERM -> "Giữa kỳ";
            case FINAL -> "Cuối kỳ";
            case QUIZ -> "Kiểm tra";
            case PRACTICE -> "Luyện tập";
        };
    }
}

