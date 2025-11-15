package com.example.backend.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Request DTO for assigning proctors to exam room
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Request để gán cán bộ coi thi vào phòng thi")
public class AssignProctorRequest {

    @NotEmpty(message = "Danh sách ID cán bộ coi thi không được để trống")
    @Schema(description = "Danh sách ID của các cán bộ coi thi", example = "[1, 2, 3]")
    private List<Long> proctorIds;
}

