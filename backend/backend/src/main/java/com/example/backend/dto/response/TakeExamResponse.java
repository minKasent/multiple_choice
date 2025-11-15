package com.example.backend.dto.response;

import com.example.backend.enums.QuestionType;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Take exam response (questions without correct answers shown)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TakeExamResponse {
    
    private Long sessionId;
    
    private String sessionCode;
    
    private String examTitle;
    
    private Integer durationMinutes;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    
    private Integer remainingTime; // Remaining time in seconds
    
    private List<ExamQuestionItem> questions;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExamQuestionItem {
        private Long questionId;
        private String content;
        private QuestionType questionType;
        private BigDecimal points;
        private List<AnswerOption> answers; // Without isCorrect flag
        private Long submittedAnswerId; // Student's submitted answer
        private String submittedAnswerText;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnswerOption {
        private Long id;
        private String content;
        private Integer displayOrder;
    }
}

