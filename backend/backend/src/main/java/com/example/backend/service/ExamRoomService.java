package com.example.backend.service;

import com.example.backend.dto.request.AssignProctorRequest;
import com.example.backend.dto.request.CreateExamRoomRequest;
import com.example.backend.dto.request.UpdateExamRoomRequest;
import com.example.backend.dto.response.ExamRoomResponse;
import com.example.backend.entity.ExamRoom;
import com.example.backend.entity.ExamRoomProctor;
import com.example.backend.entity.User;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.ExamRoomProctorRepository;
import com.example.backend.repository.ExamRoomRepository;
import com.example.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for managing exam rooms
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class ExamRoomService {

    private final ExamRoomRepository examRoomRepository;
    private final ExamRoomProctorRepository examRoomProctorRepository;
    private final UserRepository userRepository;

    /**
     * Get all exam rooms with pagination
     */
    @Transactional(readOnly = true)
    public Page<ExamRoomResponse> getAllExamRooms(Pageable pageable) {
        log.info("Getting all exam rooms with pagination: {}", pageable);
        return examRoomRepository.findAll(pageable).map(this::mapToResponse);
    }

    /**
     * Get exam room by ID
     */
    @Transactional(readOnly = true)
    public ExamRoomResponse getExamRoomById(Long id) {
        log.info("Getting exam room by ID: {}", id);
        ExamRoom examRoom = findExamRoomById(id);
        return mapToResponse(examRoom);
    }

    /**
     * Get exam room by code
     */
    @Transactional(readOnly = true)
    public ExamRoomResponse getExamRoomByCode(String code) {
        log.info("Getting exam room by code: {}", code);
        ExamRoom examRoom = examRoomRepository.findByCode(code)
                .orElseThrow(() -> new ResourceNotFoundException("Exam room not found with code: " + code));
        return mapToResponse(examRoom);
    }

    /**
     * Create new exam room
     */
    @Transactional
    public ExamRoomResponse createExamRoom(CreateExamRoomRequest request) {
        log.info("Creating exam room: {}", request.getName());

        // Check if code already exists
        if (examRoomRepository.existsByCode(request.getCode())) {
            throw new BadRequestException("Exam room code already exists: " + request.getCode());
        }

        // Get current user
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        User createdBy = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        ExamRoom examRoom = ExamRoom.builder()
                .name(request.getName())
                .code(request.getCode())
                .location(request.getLocation())
                .capacity(request.getCapacity())
                .description(request.getDescription())
                .createdBy(createdBy)
                .build();

        ExamRoom saved = examRoomRepository.save(examRoom);
        log.info("Created exam room with ID: {}", saved.getId());

        return mapToResponse(saved);
    }

    /**
     * Update exam room
     */
    @Transactional
    public ExamRoomResponse updateExamRoom(Long id, UpdateExamRoomRequest request) {
        log.info("Updating exam room with ID: {}", id);

        ExamRoom examRoom = findExamRoomById(id);

        if (request.getName() != null) {
            examRoom.setName(request.getName());
        }
        if (request.getLocation() != null) {
            examRoom.setLocation(request.getLocation());
        }
        if (request.getCapacity() != null) {
            examRoom.setCapacity(request.getCapacity());
        }
        if (request.getDescription() != null) {
            examRoom.setDescription(request.getDescription());
        }

        ExamRoom updated = examRoomRepository.save(examRoom);
        log.info("Updated exam room with ID: {}", updated.getId());

        return mapToResponse(updated);
    }

    /**
     * Delete exam room
     */
    @Transactional
    public void deleteExamRoom(Long id) {
        log.info("Deleting exam room with ID: {}", id);

        ExamRoom examRoom = findExamRoomById(id);
        examRoomRepository.delete(examRoom);

        log.info("Deleted exam room with ID: {}", id);
    }

    /**
     * Assign proctors to exam room
     */
    @Transactional
    public ExamRoomResponse assignProctors(Long examRoomId, AssignProctorRequest request) {
        log.info("Assigning proctors to exam room ID: {}", examRoomId);

        ExamRoom examRoom = findExamRoomById(examRoomId);

        // Get current user
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        User assignedBy = userRepository.findByEmail(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // Remove existing proctors
        examRoomProctorRepository.deleteByExamRoomId(examRoomId);

        // Add new proctors
        for (Long proctorId : request.getProctorIds()) {
            User proctor = userRepository.findById(proctorId)
                    .orElseThrow(() -> new ResourceNotFoundException("Proctor not found with ID: " + proctorId));

            ExamRoomProctor examRoomProctor = ExamRoomProctor.builder()
                    .examRoom(examRoom)
                    .proctor(proctor)
                    .assignedBy(assignedBy)
                    .build();

            examRoomProctorRepository.save(examRoomProctor);
        }

        log.info("Assigned {} proctors to exam room ID: {}", request.getProctorIds().size(), examRoomId);

        return getExamRoomById(examRoomId);
    }

    /**
     * Remove proctor from exam room
     */
    @Transactional
    public ExamRoomResponse removeProctor(Long examRoomId, Long proctorId) {
        log.info("Removing proctor ID {} from exam room ID: {}", proctorId, examRoomId);

        ExamRoom examRoom = findExamRoomById(examRoomId);
        User proctor = userRepository.findById(proctorId)
                .orElseThrow(() -> new ResourceNotFoundException("Proctor not found with ID: " + proctorId));

        examRoomProctorRepository.deleteByExamRoomIdAndProctorId(examRoomId, proctorId);

        log.info("Removed proctor ID {} from exam room ID: {}", proctorId, examRoomId);

        return getExamRoomById(examRoomId);
    }

    /**
     * Find exam room by ID or throw exception
     */
    private ExamRoom findExamRoomById(Long id) {
        return examRoomRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exam room not found with ID: " + id));
    }

    /**
     * Map ExamRoom entity to ExamRoomResponse DTO
     */
    private ExamRoomResponse mapToResponse(ExamRoom examRoom) {
        List<ExamRoomProctor> proctors = examRoomProctorRepository.findByExamRoomId(examRoom.getId());

        return ExamRoomResponse.builder()
                .id(examRoom.getId())
                .name(examRoom.getName())
                .code(examRoom.getCode())
                .location(examRoom.getLocation())
                .capacity(examRoom.getCapacity())
                .description(examRoom.getDescription())
                .proctors(proctors.stream()
                        .map(erp -> ExamRoomResponse.ProctorInfo.builder()
                                .id(erp.getProctor().getId())
                                .fullName(erp.getProctor().getFullName())
                                .email(erp.getProctor().getEmail())
                                .assignedAt(erp.getAssignedAt())
                                .build())
                        .collect(Collectors.toList()))
                .createdAt(examRoom.getCreatedAt())
                .updatedAt(examRoom.getUpdatedAt())
                .build();
    }
}

