package com.example.backend.dto.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Response DTO for exam room
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Response chứa thông tin phòng thi")
public class ExamRoomResponse {

    @Schema(description = "ID phòng thi", example = "1")
    private Long id;

    @Schema(description = "Tên phòng thi", example = "Phòng A1")
    private String name;

    @Schema(description = "Mã phòng thi", example = "PA001")
    private String code;

    @Schema(description = "Vị trí phòng thi", example = "Tầng 3, Nhà A")
    private String location;

    @Schema(description = "Sức chứa phòng thi", example = "50")
    private Integer capacity;

    @Schema(description = "Mô tả phòng thi")
    private String description;

    @Schema(description = "Danh sách cán bộ coi thi")
    private List<ProctorInfo> proctors;

    @Schema(description = "Thời gian tạo")
    private LocalDateTime createdAt;

    @Schema(description = "Thời gian cập nhật")
    private LocalDateTime updatedAt;

    /**
     * Proctor information
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ProctorInfo {
        @Schema(description = "ID cán bộ coi thi")
        private Long id;

        @Schema(description = "Họ tên")
        private String fullName;

        @Schema(description = "Email")
        private String email;

        @Schema(description = "Thời gian gán")
        private LocalDateTime assignedAt;
    }
}

