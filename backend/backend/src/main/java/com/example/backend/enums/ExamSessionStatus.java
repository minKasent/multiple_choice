package com.example.backend.enums;

/**
 * Enum representing the status of an exam session
 */
public enum ExamSessionStatus {
    /**
     * Exam is scheduled but not started yet
     */
    SCHEDULED,
    
    /**
     * Exam is currently in progress
     */
    IN_PROGRESS,
    
    /**
     * Exam has been completed
     */
    COMPLETED,
    
    /**
     * Exam was cancelled
     */
    CANCELLED,
    
    /**
     * Student missed the exam
     */
    MISSED;
    
    /**
     * Get display name for the status
     */
    public String getDisplayName() {
        return switch (this) {
            case SCHEDULED -> "Đã lên lịch";
            case IN_PROGRESS -> "Đang thi";
            case COMPLETED -> "Hoàn thành";
            case CANCELLED -> "Đã hủy";
            case MISSED -> "Vắng mặt";
        };
    }
}

