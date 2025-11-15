package com.example.backend.mapper;

import com.example.backend.dto.response.SubjectResponse;
import com.example.backend.entity.Subject;
import com.example.backend.repository.ChapterRepository;
import com.example.backend.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

/**
 * Mapper for Subject entity to DTOs
 */
@Component
@RequiredArgsConstructor
public class SubjectMapper {
    
    private final ChapterRepository chapterRepository;
    private final QuestionRepository questionRepository;
    
    public SubjectResponse toSubjectResponse(Subject subject) {
        if (subject == null) {
            return null;
        }
        
        return SubjectResponse.builder()
                .id(subject.getId())
                .code(subject.getCode())
                .name(subject.getName())
                .description(subject.getDescription())
                .creditHours(subject.getCreditHours())
                .isActive(subject.getIsActive())
                .chapterCount(chapterRepository.countBySubject(subject))
                .questionCount(questionRepository.countBySubjectId(subject.getId()))
                .createdAt(subject.getCreatedAt())
                .updatedAt(subject.getUpdatedAt())
                .createdBy(subject.getCreatedBy() != null ? subject.getCreatedBy().getFullName() : null)
                .build();
    }
    
    public SubjectResponse toSubjectResponseSimple(Subject subject) {
        if (subject == null) {
            return null;
        }
        
        return SubjectResponse.builder()
                .id(subject.getId())
                .code(subject.getCode())
                .name(subject.getName())
                .description(subject.getDescription())
                .creditHours(subject.getCreditHours())
                .isActive(subject.getIsActive())
                .createdAt(subject.getCreatedAt())
                .updatedAt(subject.getUpdatedAt())
                .build();
    }
}

