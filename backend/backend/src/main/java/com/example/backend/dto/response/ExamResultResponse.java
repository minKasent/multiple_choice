package com.example.backend.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Exam result response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamResultResponse {
    
    private Long sessionId;
    
    private String sessionCode;
    
    private String examTitle;
    
    private String studentName;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime completedAt;
    
    private BigDecimal totalScore;
    
    private BigDecimal maxScore;
    
    private BigDecimal percentageScore;
    
    private Boolean isPassed;
    
    private BigDecimal passingScore;
    
    private Integer correctAnswers;
    
    private Integer totalQuestions;
    
    private Integer violationCount;
    
    private List<QuestionResult> questionResults; // Only if review is allowed
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuestionResult {
        private Long questionId;
        private String content;
        private String studentAnswer;
        private String correctAnswer;
        private Boolean isCorrect;
        private BigDecimal pointsEarned;
        private BigDecimal maxPoints;
        private String explanation;
    }
}

