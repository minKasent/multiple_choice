package com.example.backend.controller;

import com.example.backend.dto.request.AddQuestionsToExamRequest;
import com.example.backend.dto.request.CreateExamRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.ExamDetailResponse;
import com.example.backend.dto.response.ExamResponse;
import com.example.backend.service.ExamService;
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

/**
 * REST Controller for exam management
 */
@RestController
@RequestMapping("/exams")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Exam Management", description = "Exam management APIs")
public class ExamController {

    private final ExamService examService;

    /**
     * Get all exams
     */
    @GetMapping
    @Operation(summary = "Get all exams", description = "Get paginated list of all exams")
    public ResponseEntity<ApiResponse<Page<ExamResponse>>> getAllExams(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        Page<ExamResponse> exams = examService.getAllExams(pageable);
        return ResponseEntity.ok(ApiResponse.success(exams));
    }

    /**
     * Get exams by subject
     */
    @GetMapping("/subject/{subjectId}")
    @Operation(summary = "Get exams by subject", description = "Get exams filtered by subject")
    public ResponseEntity<ApiResponse<Page<ExamResponse>>> getExamsBySubject(
            @PathVariable Long subjectId,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Page<ExamResponse> exams = examService.getExamsBySubject(subjectId, pageable);
        return ResponseEntity.ok(ApiResponse.success(exams));
    }

    /**
     * Search exams
     */
    @GetMapping("/search")
    @Operation(summary = "Search exams", description = "Search exams by keyword")
    public ResponseEntity<ApiResponse<Page<ExamResponse>>> searchExams(
            @RequestParam String keyword,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Page<ExamResponse> exams = examService.searchExams(keyword, pageable);
        return ResponseEntity.ok(ApiResponse.success(exams));
    }

    /**
     * Get exam by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get exam by ID", description = "Get exam basic information")
    public ResponseEntity<ApiResponse<ExamResponse>> getExamById(@PathVariable Long id) {
        ExamResponse exam = examService.getExamById(id);
        return ResponseEntity.ok(ApiResponse.success(exam));
    }

    /**
     * Get exam detail with questions
     */
    @GetMapping("/{id}/detail")
    @Operation(summary = "Get exam detail", description = "Get exam with all questions and answers")
    public ResponseEntity<ApiResponse<ExamDetailResponse>> getExamDetail(@PathVariable Long id) {
        ExamDetailResponse exam = examService.getExamDetail(id);
        return ResponseEntity.ok(ApiResponse.success(exam));
    }

    /**
     * Create new exam
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create exam", description = "Create a new exam (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<ExamResponse>> createExam(
            @Valid @RequestBody CreateExamRequest request
    ) {
        ExamResponse exam = examService.createExam(request);
        return ResponseEntity.ok(ApiResponse.success("Exam created successfully", exam));
    }

    /**
     * Update exam
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Update exam", description = "Update exam information")
    public ResponseEntity<ApiResponse<ExamResponse>> updateExam(
            @PathVariable Long id,
            @Valid @RequestBody CreateExamRequest request
    ) {
        ExamResponse exam = examService.updateExam(id, request);
        return ResponseEntity.ok(ApiResponse.success("Exam updated successfully", exam));
    }

    /**
     * Delete exam
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Delete exam", description = "Soft delete an exam")
    public ResponseEntity<ApiResponse<Void>> deleteExam(@PathVariable Long id) {
        examService.deleteExam(id);
        return ResponseEntity.ok(ApiResponse.success("Exam deleted successfully"));
    }

    /**
     * Add questions to exam
     */
    @PostMapping("/{id}/questions")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Add questions to exam", description = "Add multiple questions to exam")
    public ResponseEntity<ApiResponse<ExamDetailResponse>> addQuestionsToExam(
            @PathVariable Long id,
            @Valid @RequestBody AddQuestionsToExamRequest request
    ) {
        ExamDetailResponse exam = examService.addQuestionsToExam(id, request);
        return ResponseEntity.ok(ApiResponse.success("Questions added successfully", exam));
    }

    /**
     * Remove question from exam
     */
    @DeleteMapping("/{examId}/questions/{questionId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Remove question from exam", description = "Remove a question from exam")
    public ResponseEntity<ApiResponse<Void>> removeQuestionFromExam(
            @PathVariable Long examId,
            @PathVariable Long questionId
    ) {
        examService.removeQuestionFromExam(examId, questionId);
        return ResponseEntity.ok(ApiResponse.success("Question removed successfully"));
    }

    /**
     * Shuffle exam questions
     */
    @PostMapping("/{id}/shuffle")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Shuffle exam", description = "Randomize question order in exam")
    public ResponseEntity<ApiResponse<ExamDetailResponse>> shuffleExam(@PathVariable Long id) {
        ExamDetailResponse exam = examService.shuffleExam(id);
        return ResponseEntity.ok(ApiResponse.success("Exam shuffled successfully", exam));
    }

    /**
     * Clone exam
     */
    @PostMapping("/{id}/clone")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Clone exam", description = "Create a copy of existing exam")
    public ResponseEntity<ApiResponse<ExamResponse>> cloneExam(@PathVariable Long id) {
        ExamResponse exam = examService.cloneExam(id);
        return ResponseEntity.ok(ApiResponse.success("Exam cloned successfully", exam));
    }
}

