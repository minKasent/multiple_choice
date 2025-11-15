package com.example.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Submit answer request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SubmitAnswerRequest {
    
    @NotNull(message = "Question ID is required")
    private Long questionId;
    
    private Long answerId; // For multiple choice (single answer)
    
    private List<Long> answerIds; // For multiple choice (multiple answers)
    
    private String answerText; // For fill-in-blank
    
    private Integer timeSpentSeconds;
}

