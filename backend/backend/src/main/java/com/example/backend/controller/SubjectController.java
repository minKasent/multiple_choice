package com.example.backend.controller;

import com.example.backend.dto.request.CreateSubjectRequest;
import com.example.backend.dto.request.UpdateSubjectRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.SubjectResponse;
import com.example.backend.service.SubjectService;
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
 * REST Controller for subject management
 */
@RestController
@RequestMapping("/subjects")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
@Tag(name = "Subject Management", description = "Subject management APIs")
public class SubjectController {

    private final SubjectService subjectService;

    /**
     * Get all subjects with pagination
     */
    @GetMapping
    @Operation(summary = "Get all subjects", description = "Get paginated list of all subjects")
    public ResponseEntity<ApiResponse<Page<SubjectResponse>>> getAllSubjects(
            @PageableDefault(size = 20, sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        Page<SubjectResponse> subjects = subjectService.getAllSubjects(pageable);
        return ResponseEntity.ok(ApiResponse.success(subjects));
    }

    /**
     * Get all subjects as list (no pagination)
     */
    @GetMapping("/list")
    @Operation(summary = "Get all subjects list", description = "Get list of all subjects without pagination")
    public ResponseEntity<ApiResponse<List<SubjectResponse>>> getAllSubjectsList() {
        List<SubjectResponse> subjects = subjectService.getAllSubjectsList();
        return ResponseEntity.ok(ApiResponse.success(subjects));
    }

    /**
     * Search subjects
     */
    @GetMapping("/search")
    @Operation(summary = "Search subjects", description = "Search subjects by keyword")
    public ResponseEntity<ApiResponse<Page<SubjectResponse>>> searchSubjects(
            @RequestParam String keyword,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Page<SubjectResponse> subjects = subjectService.searchSubjects(keyword, pageable);
        return ResponseEntity.ok(ApiResponse.success(subjects));
    }

    /**
     * Get subject by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get subject by ID", description = "Get subject details by ID")
    public ResponseEntity<ApiResponse<SubjectResponse>> getSubjectById(@PathVariable Long id) {
        SubjectResponse subject = subjectService.getSubjectById(id);
        return ResponseEntity.ok(ApiResponse.success(subject));
    }

    /**
     * Get subject by code
     */
    @GetMapping("/code/{code}")
    @Operation(summary = "Get subject by code", description = "Get subject details by code")
    public ResponseEntity<ApiResponse<SubjectResponse>> getSubjectByCode(@PathVariable String code) {
        SubjectResponse subject = subjectService.getSubjectByCode(code);
        return ResponseEntity.ok(ApiResponse.success(subject));
    }

    /**
     * Create new subject
     */
    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Create subject", description = "Create a new subject (Admin/Teacher only)")
    public ResponseEntity<ApiResponse<SubjectResponse>> createSubject(
            @Valid @RequestBody CreateSubjectRequest request
    ) {
        SubjectResponse subject = subjectService.createSubject(request);
        return ResponseEntity.ok(ApiResponse.success("Subject created successfully", subject));
    }

    /**
     * Update subject
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Update subject", description = "Update subject information")
    public ResponseEntity<ApiResponse<SubjectResponse>> updateSubject(
            @PathVariable Long id,
            @Valid @RequestBody UpdateSubjectRequest request
    ) {
        SubjectResponse subject = subjectService.updateSubject(id, request);
        return ResponseEntity.ok(ApiResponse.success("Subject updated successfully", subject));
    }

    /**
     * Delete subject
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete subject", description = "Soft delete a subject (Admin only)")
    public ResponseEntity<ApiResponse<Void>> deleteSubject(@PathVariable Long id) {
        subjectService.deleteSubject(id);
        return ResponseEntity.ok(ApiResponse.success("Subject deleted successfully"));
    }
}

