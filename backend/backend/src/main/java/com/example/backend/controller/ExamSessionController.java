package com.example.backend.controller;

import com.example.backend.dto.request.ScheduleExamRequest;
import com.example.backend.dto.request.SubmitAnswerRequest;
import com.example.backend.dto.response.*;
import com.example.backend.service.ExamSessionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for exam session management and taking exams
 */
@RestController
@RequestMapping("/exam-sessions")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Exam Session Management", description = "Exam session and exam taking APIs")
public class ExamSessionController {

    private final ExamSessionService examSessionService;

    /**
     * Schedule exam sessions (Admin/Teacher)
     */
    @PostMapping("/schedule")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Schedule exam", description = "Schedule exam sessions for students (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<List<ExamSessionResponse>>> scheduleExam(
            @Valid @RequestBody ScheduleExamRequest request
    ) {
        List<ExamSessionResponse> sessions = examSessionService.scheduleExam(request);
        return ResponseEntity.ok(ApiResponse.success("Exam scheduled successfully", sessions));
    }

    /**
     * Get my exams (Student)
     */
    @GetMapping("/my-exams")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Get my exams", description = "Get list of student's exam sessions")
    public ResponseEntity<ApiResponse<Page<ExamSessionResponse>>> getMyExams(
            @PageableDefault(size = 20, sort = "startTime", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        Page<ExamSessionResponse> sessions = examSessionService.getMyExams(pageable);
        return ResponseEntity.ok(ApiResponse.success(sessions));
    }

    /**
     * Get exam session by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get exam session", description = "Get exam session details")
    public ResponseEntity<ApiResponse<ExamSessionResponse>> getExamSession(@PathVariable Long id) {
        ExamSessionResponse session = examSessionService.getExamSession(id);
        return ResponseEntity.ok(ApiResponse.success(session));
    }

    /**
     * Start exam (Student)
     */
    @PostMapping("/{id}/start")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Start exam", description = "Start taking an exam")
    public ResponseEntity<ApiResponse<TakeExamResponse>> startExam(@PathVariable Long id) {
        TakeExamResponse exam = examSessionService.startExam(id);
        return ResponseEntity.ok(ApiResponse.success("Exam started successfully", exam));
    }

    /**
     * Submit answer (Student)
     */
    @PostMapping("/{id}/submit-answer")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Submit answer", description = "Submit answer for a question")
    public ResponseEntity<ApiResponse<Void>> submitAnswer(
            @PathVariable Long id,
            @Valid @RequestBody SubmitAnswerRequest request
    ) {
        examSessionService.submitAnswer(id, request);
        return ResponseEntity.ok(ApiResponse.success("Answer submitted successfully"));
    }

    /**
     * Complete exam (Student)
     */
    @PostMapping("/{id}/complete")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Complete exam", description = "Complete and submit exam for grading")
    public ResponseEntity<ApiResponse<ExamResultResponse>> completeExam(@PathVariable Long id) {
        ExamResultResponse result = examSessionService.completeExam(id);
        return ResponseEntity.ok(ApiResponse.success("Exam completed and graded successfully", result));
    }

    /**
     * Get exam result
     */
    @GetMapping("/{id}/result")
    @Operation(summary = "Get exam result", description = "Get exam result with scores")
    public ResponseEntity<ApiResponse<ExamResultResponse>> getExamResult(@PathVariable Long id) {
        ExamResultResponse result = examSessionService.getExamResult(id);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    /**
     * Report violation (Client-side detection)
     */
    @PostMapping("/{id}/violation")
    @PreAuthorize("hasRole('STUDENT')")
    @Operation(summary = "Report violation", description = "Report exam violation (tab switch, etc.)")
    public ResponseEntity<ApiResponse<Void>> reportViolation(@PathVariable Long id) {
        examSessionService.reportViolation(id);
        return ResponseEntity.ok(ApiResponse.success("Violation reported"));
    }
}

