package com.example.backend.controller;

import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.StatisticsResponse;
import com.example.backend.service.StatisticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller for statistics and analytics
 */
@RestController
@RequestMapping("/statistics")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Statistics & Analytics", description = "Statistics and analytics APIs")
public class StatisticsController {

    private final StatisticsService statisticsService;

    /**
     * Get student statistics
     */
    @GetMapping("/student/{studentId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER') or @statisticsService.getCurrentUser().id == #studentId")
    @Operation(summary = "Get student statistics", description = "Get performance statistics for a student")
    public ResponseEntity<ApiResponse<StatisticsResponse.StudentStats>> getStudentStatistics(
            @PathVariable Long studentId
    ) {
        StatisticsResponse.StudentStats stats = statisticsService.getStudentStatistics(studentId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * Get my statistics (current student)
     */
    @GetMapping("/my-stats")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get my statistics", description = "Get statistics for current student")
    public ResponseEntity<ApiResponse<StatisticsResponse.StudentStats>> getMyStatistics() {
        StatisticsResponse.StudentStats stats = statisticsService.getMyStatistics();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * Get exam statistics
     */
    @GetMapping("/exam/{examId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Get exam statistics", description = "Get statistics for an exam")
    public ResponseEntity<ApiResponse<StatisticsResponse.ExamStats>> getExamStatistics(
            @PathVariable Long examId
    ) {
        StatisticsResponse.ExamStats stats = statisticsService.getExamStatistics(examId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * Get subject statistics
     */
    @GetMapping("/subject/{subjectId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Get subject statistics", description = "Get statistics for a subject")
    public ResponseEntity<ApiResponse<StatisticsResponse.SubjectStats>> getSubjectStatistics(
            @PathVariable Long subjectId
    ) {
        StatisticsResponse.SubjectStats stats = statisticsService.getSubjectStatistics(subjectId);
        return ResponseEntity.ok(ApiResponse.success(stats));
    }

    /**
     * Get dashboard statistics
     */
    @GetMapping("/dashboard")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Get dashboard statistics", description = "Get overall system statistics")
    public ResponseEntity<ApiResponse<StatisticsResponse.DashboardStats>> getDashboardStatistics() {
        StatisticsResponse.DashboardStats stats = statisticsService.getDashboardStatistics();
        return ResponseEntity.ok(ApiResponse.success(stats));
    }
}

