package com.example.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Schedule exam request DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScheduleExamRequest {
    
    @NotNull(message = "Exam ID is required")
    private Long examId;
    
    private Long examRoomId;
    
    @NotNull(message = "Student IDs are required")
    private List<Long> studentIds;
    
    @NotNull(message = "Start time is required")
    private LocalDateTime startTime;
    
    // End time will be calculated based on exam duration
}

