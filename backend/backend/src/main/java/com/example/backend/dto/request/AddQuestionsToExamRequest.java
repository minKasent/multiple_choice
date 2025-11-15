package com.example.backend.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Add questions to exam request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AddQuestionsToExamRequest {
    
    @NotEmpty(message = "Question list cannot be empty")
    @Valid
    private List<ExamQuestionItem> questions;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExamQuestionItem {
        
        @NotNull(message = "Question ID is required")
        private Long questionId;
        
        @NotNull(message = "Display order is required")
        private Integer displayOrder;
        
        @NotNull(message = "Points are required")
        private BigDecimal points;
    }
}

