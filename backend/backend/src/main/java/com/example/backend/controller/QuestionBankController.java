package com.example.backend.controller;

import com.example.backend.dto.request.CreateChapterRequest;
import com.example.backend.dto.request.CreatePassageRequest;
import com.example.backend.dto.request.CreateQuestionRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.ChapterResponse;
import com.example.backend.dto.response.PassageResponse;
import com.example.backend.dto.response.QuestionResponse;
import com.example.backend.service.QuestionBankService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST Controller for question bank management (Chapter, Passage, Question)
 */
@RestController
@RequestMapping("/question-bank")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Question Bank Management", description = "Question bank management APIs")
public class QuestionBankController {

    private final QuestionBankService questionBankService;

    // ==================== CHAPTER ENDPOINTS ====================

    /**
     * Get all chapters by subject
     */
    @GetMapping("/subjects/{subjectId}/chapters")
    @Operation(summary = "Get chapters by subject", description = "Get all chapters for a subject")
    public ResponseEntity<ApiResponse<List<ChapterResponse>>> getChaptersBySubject(
            @PathVariable Long subjectId
    ) {
        List<ChapterResponse> chapters = questionBankService.getChaptersBySubject(subjectId);
        return ResponseEntity.ok(ApiResponse.success(chapters));
    }

    /**
     * Get chapter by ID
     */
    @GetMapping("/chapters/{id}")
    @Operation(summary = "Get chapter by ID", description = "Get chapter details by ID")
    public ResponseEntity<ApiResponse<ChapterResponse>> getChapterById(@PathVariable Long id) {
        ChapterResponse chapter = questionBankService.getChapterById(id);
        return ResponseEntity.ok(ApiResponse.success(chapter));
    }

    /**
     * Create new chapter
     */
    @PostMapping("/subjects/{subjectId}/chapters")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create chapter", description = "Create a new chapter (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<ChapterResponse>> createChapter(
            @PathVariable Long subjectId,
            @Valid @RequestBody CreateChapterRequest request
    ) {
        ChapterResponse chapter = questionBankService.createChapter(subjectId, request);
        return ResponseEntity.ok(ApiResponse.success("Chapter created successfully", chapter));
    }

    /**
     * Update chapter
     */
    @PutMapping("/chapters/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Update chapter", description = "Update chapter information")
    public ResponseEntity<ApiResponse<ChapterResponse>> updateChapter(
            @PathVariable Long id,
            @Valid @RequestBody CreateChapterRequest request
    ) {
        ChapterResponse chapter = questionBankService.updateChapter(id, request);
        return ResponseEntity.ok(ApiResponse.success("Chapter updated successfully", chapter));
    }

    /**
     * Delete chapter
     */
    @DeleteMapping("/chapters/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Delete chapter", description = "Soft delete a chapter")
    public ResponseEntity<ApiResponse<Void>> deleteChapter(@PathVariable Long id) {
        questionBankService.deleteChapter(id);
        return ResponseEntity.ok(ApiResponse.success("Chapter deleted successfully"));
    }

    // ==================== PASSAGE ENDPOINTS ====================

    /**
     * Get all passages by chapter
     */
    @GetMapping("/chapters/{chapterId}/passages")
    @Operation(summary = "Get passages by chapter", description = "Get all passages for a chapter")
    public ResponseEntity<ApiResponse<List<PassageResponse>>> getPassagesByChapter(
            @PathVariable Long chapterId
    ) {
        List<PassageResponse> passages = questionBankService.getPassagesByChapter(chapterId);
        return ResponseEntity.ok(ApiResponse.success(passages));
    }

    /**
     * Get passage by ID
     */
    @GetMapping("/passages/{id}")
    @Operation(summary = "Get passage by ID", description = "Get passage details by ID")
    public ResponseEntity<ApiResponse<PassageResponse>> getPassageById(@PathVariable Long id) {
        PassageResponse passage = questionBankService.getPassageById(id);
        return ResponseEntity.ok(ApiResponse.success(passage));
    }

    /**
     * Create new passage
     */
    @PostMapping("/chapters/{chapterId}/passages")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create passage", description = "Create a new passage (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<PassageResponse>> createPassage(
            @PathVariable Long chapterId,
            @Valid @RequestBody CreatePassageRequest request
    ) {
        PassageResponse passage = questionBankService.createPassage(chapterId, request);
        return ResponseEntity.ok(ApiResponse.success("Passage created successfully", passage));
    }

    /**
     * Update passage
     */
    @PutMapping("/passages/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Update passage", description = "Update passage information")
    public ResponseEntity<ApiResponse<PassageResponse>> updatePassage(
            @PathVariable Long id,
            @Valid @RequestBody CreatePassageRequest request
    ) {
        PassageResponse passage = questionBankService.updatePassage(id, request);
        return ResponseEntity.ok(ApiResponse.success("Passage updated successfully", passage));
    }

    /**
     * Delete passage
     */
    @DeleteMapping("/passages/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Delete passage", description = "Soft delete a passage")
    public ResponseEntity<ApiResponse<Void>> deletePassage(@PathVariable Long id) {
        questionBankService.deletePassage(id);
        return ResponseEntity.ok(ApiResponse.success("Passage deleted successfully"));
    }

    // ==================== QUESTION ENDPOINTS ====================

    /**
     * Get all questions by chapter
     */
    @GetMapping("/chapters/{chapterId}/questions")
    @Operation(summary = "Get questions by chapter", description = "Get all questions for a chapter")
    public ResponseEntity<ApiResponse<List<QuestionResponse>>> getQuestionsByChapter(
            @PathVariable Long chapterId
    ) {
        List<QuestionResponse> questions = questionBankService.getQuestionsByChapter(chapterId);
        return ResponseEntity.ok(ApiResponse.success(questions));
    }

    /**
     * Get all questions by passage
     */
    @GetMapping("/passages/{passageId}/questions")
    @Operation(summary = "Get questions by passage", description = "Get all questions for a passage")
    public ResponseEntity<ApiResponse<List<QuestionResponse>>> getQuestionsByPassage(
            @PathVariable Long passageId
    ) {
        List<QuestionResponse> questions = questionBankService.getQuestionsByPassage(passageId);
        return ResponseEntity.ok(ApiResponse.success(questions));
    }

    /**
     * Get question by ID
     */
    @GetMapping("/questions/{id}")
    @Operation(summary = "Get question by ID", description = "Get question details with answers by ID")
    public ResponseEntity<ApiResponse<QuestionResponse>> getQuestionById(@PathVariable Long id) {
        QuestionResponse question = questionBankService.getQuestionById(id);
        return ResponseEntity.ok(ApiResponse.success(question));
    }

    /**
     * Create new question with answers for a chapter
     */
    @PostMapping("/chapters/{chapterId}/questions")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create question for chapter", description = "Create a new question for a chapter (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<QuestionResponse>> createQuestionForChapter(
            @PathVariable Long chapterId,
            @Valid @RequestBody CreateQuestionRequest request
    ) {
        QuestionResponse question = questionBankService.createQuestionForChapter(chapterId, request);
        return ResponseEntity.ok(ApiResponse.success("Question created successfully", question));
    }

    /**
     * Create new question with answers for a passage
     */
    @PostMapping("/passages/{passageId}/questions")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create question for passage", description = "Create a new question for a passage (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<QuestionResponse>> createQuestionForPassage(
            @PathVariable Long passageId,
            @Valid @RequestBody CreateQuestionRequest request
    ) {
        QuestionResponse question = questionBankService.createQuestionForPassage(passageId, request);
        return ResponseEntity.ok(ApiResponse.success("Question created successfully", question));
    }

    /**
     * Update question
     */
    @PutMapping("/questions/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Update question", description = "Update question and answers")
    public ResponseEntity<ApiResponse<QuestionResponse>> updateQuestion(
            @PathVariable Long id,
            @Valid @RequestBody CreateQuestionRequest request
    ) {
        QuestionResponse question = questionBankService.updateQuestion(id, request);
        return ResponseEntity.ok(ApiResponse.success("Question updated successfully", question));
    }

    /**
     * Delete question
     */
    @DeleteMapping("/questions/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Delete question", description = "Soft delete a question")
    public ResponseEntity<ApiResponse<Void>> deleteQuestion(@PathVariable Long id) {
        questionBankService.deleteQuestion(id);
        return ResponseEntity.ok(ApiResponse.success("Question deleted successfully"));
    }
}

