package com.example.backend.dto.request;

import com.example.backend.enums.DifficultyLevel;
import com.example.backend.enums.QuestionType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Create question request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateQuestionRequest {
    
    @NotNull(message = "Question type is required")
    private QuestionType questionType;
    
    @NotBlank(message = "Question content is required")
    private String content;
    
    private String explanation;
    
    private DifficultyLevel difficultyLevel;
    
    @Builder.Default
    private Double points = 1.0;
    
    @NotNull(message = "Display order is required")
    @Min(value = 1, message = "Display order must be at least 1")
    private Integer displayOrder;
    
    @Valid
    private List<CreateAnswerRequest> answers;
    
    /**
     * Answer request DTO
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateAnswerRequest {
        
        @NotBlank(message = "Answer content is required")
        private String content;
        
        @NotNull(message = "isCorrect flag is required")
        private Boolean isCorrect;
        
        @NotNull(message = "Display order is required")
        @Min(value = 1, message = "Display order must be at least 1")
        private Integer displayOrder;
    }
}

