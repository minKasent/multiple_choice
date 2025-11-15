package com.example.backend.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating exam room
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Request để tạo phòng thi mới")
public class CreateExamRoomRequest {

    @NotBlank(message = "Tên phòng thi không được để trống")
    @Size(max = 255, message = "Tên phòng thi không được vượt quá 255 ký tự")
    @Schema(description = "Tên phòng thi", example = "Phòng A1")
    private String name;

    @NotBlank(message = "Mã phòng thi không được để trống")
    @Size(max = 50, message = "Mã phòng thi không được vượt quá 50 ký tự")
    @Schema(description = "Mã phòng thi (duy nhất)", example = "PA001")
    private String code;

    @Schema(description = "Vị trí phòng thi", example = "Tầng 3, Nhà A")
    private String location;

    @Positive(message = "Sức chứa phải là số dương")
    @Schema(description = "Sức chứa phòng thi", example = "50")
    private Integer capacity;

    @Schema(description = "Mô tả phòng thi", example = "Phòng thi có máy lạnh, máy chiếu")
    private String description;
}

