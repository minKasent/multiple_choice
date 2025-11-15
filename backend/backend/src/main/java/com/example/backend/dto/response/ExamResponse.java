package com.example.backend.dto.response;

import com.example.backend.enums.ExamType;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Exam response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamResponse {
    
    private Long id;
    
    private Long subjectId;
    
    private String subjectName;
    
    private String title;
    
    private String description;
    
    private Integer durationMinutes;
    
    private Integer totalQuestions;
    
    private BigDecimal totalPoints;
    
    private BigDecimal passingScore;
    
    private ExamType examType;
    
    private Boolean isShuffled;
    
    private Boolean isShuffleAnswers;
    
    private Boolean showResultImmediately;
    
    private Boolean allowReview;
    
    private Boolean isActive;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    private String createdBy;
}

