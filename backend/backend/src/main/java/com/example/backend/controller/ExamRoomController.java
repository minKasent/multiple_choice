package com.example.backend.controller;

import com.example.backend.dto.request.AssignProctorRequest;
import com.example.backend.dto.request.CreateExamRoomRequest;
import com.example.backend.dto.request.UpdateExamRoomRequest;
import com.example.backend.dto.response.ApiResponse;
import com.example.backend.dto.response.ExamRoomResponse;
import com.example.backend.service.ExamRoomService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller for exam room management
 */
@RestController
@RequestMapping("/api/exam-rooms")
@RequiredArgsConstructor
@Slf4j
@Tag(name = "Exam Room Management", description = "APIs cho quản lý phòng thi")
@SecurityRequirement(name = "Bearer Authentication")
public class ExamRoomController {

    private final ExamRoomService examRoomService;

    /**
     * Get all exam rooms with pagination
     */
    @GetMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Lấy danh sách phòng thi", description = "Lấy tất cả phòng thi với phân trang")
    public ResponseEntity<ApiResponse<Page<ExamRoomResponse>>> getAllExamRooms(
            @Parameter(description = "Số trang (bắt đầu từ 0)") @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Số lượng bản ghi trên mỗi trang") @RequestParam(defaultValue = "20") int size,
            @Parameter(description = "Sắp xếp theo trường") @RequestParam(defaultValue = "name") String sortBy,
            @Parameter(description = "Hướng sắp xếp (asc/desc)") @RequestParam(defaultValue = "asc") String direction
    ) {
        log.info("GET /api/exam-rooms - page: {}, size: {}", page, size);

        Sort sort = direction.equalsIgnoreCase("asc")
                ? Sort.by(sortBy).ascending()
                : Sort.by(sortBy).descending();

        Page<ExamRoomResponse> examRooms = examRoomService.getAllExamRooms(
                PageRequest.of(page, size, sort)
        );

        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách phòng thi thành công", examRooms));
    }

    /**
     * Get exam room by ID
     */
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Lấy chi tiết phòng thi", description = "Lấy thông tin chi tiết phòng thi theo ID")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> getExamRoomById(
            @Parameter(description = "ID của phòng thi") @PathVariable Long id
    ) {
        log.info("GET /api/exam-rooms/{}", id);
        ExamRoomResponse examRoom = examRoomService.getExamRoomById(id);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin phòng thi thành công", examRoom));
    }

    /**
     * Get exam room by code
     */
    @GetMapping("/code/{code}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Lấy phòng thi theo mã", description = "Lấy thông tin phòng thi theo mã phòng")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> getExamRoomByCode(
            @Parameter(description = "Mã phòng thi") @PathVariable String code
    ) {
        log.info("GET /api/exam-rooms/code/{}", code);
        ExamRoomResponse examRoom = examRoomService.getExamRoomByCode(code);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin phòng thi thành công", examRoom));
    }

    /**
     * Create new exam room
     */
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Tạo phòng thi mới", description = "Tạo phòng thi mới (chỉ Admin)")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> createExamRoom(
            @Valid @RequestBody CreateExamRoomRequest request
    ) {
        log.info("POST /api/exam-rooms - name: {}", request.getName());
        ExamRoomResponse examRoom = examRoomService.createExamRoom(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Tạo phòng thi thành công", examRoom));
    }

    /**
     * Update exam room
     */
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Cập nhật phòng thi", description = "Cập nhật thông tin phòng thi (chỉ Admin)")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> updateExamRoom(
            @Parameter(description = "ID của phòng thi") @PathVariable Long id,
            @Valid @RequestBody UpdateExamRoomRequest request
    ) {
        log.info("PUT /api/exam-rooms/{}", id);
        ExamRoomResponse examRoom = examRoomService.updateExamRoom(id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật phòng thi thành công", examRoom));
    }

    /**
     * Delete exam room
     */
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Xóa phòng thi", description = "Xóa phòng thi (chỉ Admin)")
    public ResponseEntity<ApiResponse<Void>> deleteExamRoom(
            @Parameter(description = "ID của phòng thi") @PathVariable Long id
    ) {
        log.info("DELETE /api/exam-rooms/{}", id);
        examRoomService.deleteExamRoom(id);
        return ResponseEntity.ok(ApiResponse.<Void>success("Xóa phòng thi thành công", null));
    }

    /**
     * Assign proctors to exam room
     */
    @PostMapping("/{id}/proctors")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Gán cán bộ coi thi", description = "Gán danh sách cán bộ coi thi vào phòng thi")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> assignProctors(
            @Parameter(description = "ID của phòng thi") @PathVariable Long id,
            @Valid @RequestBody AssignProctorRequest request
    ) {
        log.info("POST /api/exam-rooms/{}/proctors", id);
        ExamRoomResponse examRoom = examRoomService.assignProctors(id, request);
        return ResponseEntity.ok(ApiResponse.success("Gán cán bộ coi thi thành công", examRoom));
    }

    /**
     * Remove proctor from exam room
     */
    @DeleteMapping("/{examRoomId}/proctors/{proctorId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'TEACHER')")
    @Operation(summary = "Xóa cán bộ coi thi", description = "Xóa cán bộ coi thi khỏi phòng thi")
    public ResponseEntity<ApiResponse<ExamRoomResponse>> removeProctor(
            @Parameter(description = "ID của phòng thi") @PathVariable Long examRoomId,
            @Parameter(description = "ID của cán bộ coi thi") @PathVariable Long proctorId
    ) {
        log.info("DELETE /api/exam-rooms/{}/proctors/{}", examRoomId, proctorId);
        ExamRoomResponse examRoom = examRoomService.removeProctor(examRoomId, proctorId);
        return ResponseEntity.ok(ApiResponse.success("Xóa cán bộ coi thi thành công", examRoom));
    }
}

