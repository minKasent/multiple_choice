package com.example.backend.dto.request;

import com.example.backend.enums.ExamType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

/**
 * Create exam request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateExamRequest {
    
    @NotNull(message = "Subject ID is required")
    private Long subjectId;
    
    @NotBlank(message = "Exam title is required")
    private String title;
    
    private String description;
    
    @NotNull(message = "Duration is required")
    @Min(value = 1, message = "Duration must be at least 1 minute")
    private Integer durationMinutes;
    
    @NotNull(message = "Passing score is required")
    private BigDecimal passingScore;
    
    private ExamType examType;
    
    private Boolean isShuffled = true;
    
    private Boolean isShuffleAnswers = true;
    
    private Boolean showResultImmediately = false;
    
    private Boolean allowReview = true;
}

