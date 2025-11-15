package com.example.backend.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Passage response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PassageResponse {
    
    private Long id;
    
    private Long chapterId;
    
    private String chapterTitle;
    
    private String title;
    
    private String content;
    
    private Integer displayOrder;
    
    private Boolean isActive;
    
    private Long questionCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}

