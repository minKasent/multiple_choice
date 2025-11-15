package com.example.backend.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Chapter response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChapterResponse {
    
    private Long id;
    
    private Long subjectId;
    
    private String subjectName;
    
    private Integer chapterNumber;
    
    private String title;
    
    private String description;
    
    private Integer displayOrder;
    
    private Boolean isActive;
    
    private Long passageCount;
    
    private Long questionCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
}

