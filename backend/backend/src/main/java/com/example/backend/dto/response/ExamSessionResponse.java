package com.example.backend.dto.response;

import com.example.backend.enums.ExamSessionStatus;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Exam session response DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamSessionResponse {
    
    private Long id;
    
    private Long examId;
    
    private String examTitle;
    
    private Long studentId;
    
    private String studentName;
    
    private String sessionCode;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime endTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime actualStartTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime actualEndTime;
    
    private ExamSessionStatus status;
    
    private BigDecimal totalScore;
    
    private BigDecimal percentageScore;
    
    private Boolean isPassed;
    
    private Integer violationCount;
    
    private Integer answeredQuestions;
    
    private Integer totalQuestions;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
}

