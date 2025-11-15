package com.example.backend.dto.response;

import com.example.backend.enums.DifficultyLevel;
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
 * Question response DTO (with answers)
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class QuestionResponse {
    
    private Long id;
    
    private Long passageId;
    
    private QuestionType questionType;
    
    private String content;
    
    private String explanation;
    
    private DifficultyLevel difficultyLevel;
    
    private BigDecimal points;
    
    private Integer displayOrder;
    
    private Boolean isActive;
    
    private List<AnswerResponse> answers;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    /**
     * Answer response DTO
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AnswerResponse {
        
        private Long id;
        
        private String content;
        
        private Boolean isCorrect;
        
        private Integer displayOrder;
    }
}

