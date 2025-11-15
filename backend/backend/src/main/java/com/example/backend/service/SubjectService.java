package com.example.backend.service;

import com.example.backend.dto.request.CreateSubjectRequest;
import com.example.backend.dto.request.UpdateSubjectRequest;
import com.example.backend.dto.response.SubjectResponse;
import com.example.backend.entity.Subject;
import com.example.backend.entity.User;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.mapper.SubjectMapper;
import com.example.backend.repository.SubjectRepository;
import com.example.backend.repository.UserRepository;
import com.example.backend.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for subject management
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class SubjectService {

    private final SubjectRepository subjectRepository;
    private final UserRepository userRepository;
    private final SubjectMapper subjectMapper;

    /**
     * Get all subjects
     */
    public Page<SubjectResponse> getAllSubjects(Pageable pageable) {
        return subjectRepository.findByIsActive(true, pageable)
                .map(subjectMapper::toSubjectResponse);
    }

    /**
     * Get all subjects (list)
     */
    public List<SubjectResponse> getAllSubjectsList() {
        return subjectRepository.findByIsActive(true).stream()
                .map(subjectMapper::toSubjectResponseSimple)
                .collect(Collectors.toList());
    }

    /**
     * Search subjects
     */
    public Page<SubjectResponse> searchSubjects(String keyword, Pageable pageable) {
        return subjectRepository.searchSubjects(keyword, pageable)
                .map(subjectMapper::toSubjectResponse);
    }

    /**
     * Get subject by ID
     */
    public SubjectResponse getSubjectById(Long id) {
        Subject subject = subjectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", id));
        return subjectMapper.toSubjectResponse(subject);
    }

    /**
     * Get subject by code
     */
    public SubjectResponse getSubjectByCode(String code) {
        Subject subject = subjectRepository.findByCode(code)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "code", code));
        return subjectMapper.toSubjectResponse(subject);
    }

    /**
     * Create new subject
     */
    @Transactional
    public SubjectResponse createSubject(CreateSubjectRequest request) {
        log.info("Creating new subject: {}", request.getCode());

        // Check if code exists
        if (subjectRepository.existsByCode(request.getCode())) {
            throw new BadRequestException("Subject code already exists: " + request.getCode());
        }

        User currentUser = getCurrentUser();

        Subject subject = Subject.builder()
                .code(request.getCode())
                .name(request.getName())
                .description(request.getDescription())
                .creditHours(request.getCreditHours())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Subject savedSubject = subjectRepository.save(subject);
        log.info("Subject created successfully: {}", savedSubject.getId());

        return subjectMapper.toSubjectResponse(savedSubject);
    }

    /**
     * Update subject
     */
    @Transactional
    public SubjectResponse updateSubject(Long id, UpdateSubjectRequest request) {
        log.info("Updating subject: {}", id);

        Subject subject = subjectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", id));

        if (request.getName() != null) {
            subject.setName(request.getName());
        }
        if (request.getDescription() != null) {
            subject.setDescription(request.getDescription());
        }
        if (request.getCreditHours() != null) {
            subject.setCreditHours(request.getCreditHours());
        }
        if (request.getIsActive() != null) {
            subject.setIsActive(request.getIsActive());
        }

        subject.setUpdatedBy(getCurrentUser());
        Subject updatedSubject = subjectRepository.save(subject);

        log.info("Subject updated successfully: {}", id);
        return subjectMapper.toSubjectResponse(updatedSubject);
    }

    /**
     * Delete subject (soft delete)
     */
    @Transactional
    public void deleteSubject(Long id) {
        log.info("Deleting subject: {}", id);

        Subject subject = subjectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", id));

        subject.setIsActive(false);
        subject.setUpdatedBy(getCurrentUser());
        subjectRepository.save(subject);

        log.info("Subject deleted successfully: {}", id);
    }

    /**
     * Get current authenticated user
     */
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Current user not found"));
    }
}

