package com.example.backend.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating exam room
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Request để cập nhật phòng thi")
public class UpdateExamRoomRequest {

    @Size(max = 255, message = "Tên phòng thi không được vượt quá 255 ký tự")
    @Schema(description = "Tên phòng thi", example = "Phòng A1")
    private String name;

    @Schema(description = "Vị trí phòng thi", example = "Tầng 3, Nhà A")
    private String location;

    @Positive(message = "Sức chứa phải là số dương")
    @Schema(description = "Sức chứa phòng thi", example = "50")
    private Integer capacity;

    @Schema(description = "Mô tả phòng thi", example = "Phòng thi có máy lạnh, máy chiếu")
    private String description;
}

