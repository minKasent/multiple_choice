package com.example.backend.mapper;

import com.example.backend.dto.response.ExamDetailResponse;
import com.example.backend.dto.response.ExamResponse;
import com.example.backend.entity.Exam;
import com.example.backend.entity.ExamQuestion;
import com.example.backend.repository.ExamQuestionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Mapper for Exam entity to DTOs
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class ExamMapper {
    
    private final ExamQuestionRepository examQuestionRepository;
    private final QuestionMapper questionMapper;
    
    public ExamResponse toExamResponse(Exam exam) {
        if (exam == null) {
            return null;
        }
        
        return ExamResponse.builder()
                .id(exam.getId())
                .subjectId(exam.getSubject().getId())
                .subjectName(exam.getSubject().getName())
                .title(exam.getTitle())
                .description(exam.getDescription())
                .durationMinutes(exam.getDurationMinutes())
                .totalQuestions(exam.getTotalQuestions())
                .totalPoints(exam.getTotalPoints())
                .passingScore(exam.getPassingScore())
                .examType(exam.getExamType())
                .isShuffled(exam.getIsShuffled())
                .isShuffleAnswers(exam.getIsShuffleAnswers())
                .showResultImmediately(exam.getShowResultImmediately())
                .allowReview(exam.getAllowReview())
                .isActive(exam.getIsActive())
                .createdAt(exam.getCreatedAt())
                .createdBy(exam.getCreatedBy() != null ? exam.getCreatedBy().getFullName() : null)
                .build();
    }
    
    public ExamDetailResponse toExamDetailResponse(Exam exam) {
        if (exam == null) {
            return null;
        }
        
        var examQuestions = examQuestionRepository.findByExamIdWithQuestion(exam.getId());
        
        return ExamDetailResponse.builder()
                .id(exam.getId())
                .subjectId(exam.getSubject() != null ? exam.getSubject().getId() : null)
                .subjectName(exam.getSubject() != null ? exam.getSubject().getName() : "Unknown")
                .title(exam.getTitle())
                .description(exam.getDescription())
                .durationMinutes(exam.getDurationMinutes())
                .totalQuestions(exam.getTotalQuestions())
                .totalPoints(exam.getTotalPoints())
                .passingScore(exam.getPassingScore())
                .examType(exam.getExamType())
                .isShuffled(exam.getIsShuffled())
                .isShuffleAnswers(exam.getIsShuffleAnswers())
                .showResultImmediately(exam.getShowResultImmediately())
                .allowReview(exam.getAllowReview())
                .isActive(exam.getIsActive())
                .questions(examQuestions.stream()
                        .map(this::toExamQuestionResponse)
                        .filter(java.util.Objects::nonNull)
                        .collect(Collectors.toList()))
                .createdAt(exam.getCreatedAt())
                .createdBy(exam.getCreatedBy() != null ? exam.getCreatedBy().getFullName() : null)
                .build();
    }
    
    private ExamDetailResponse.ExamQuestionResponse toExamQuestionResponse(ExamQuestion eq) {
        if (eq == null || eq.getQuestion() == null) {
            return null;
        }
        
        try {
            var question = eq.getQuestion();
            var questionResponse = questionMapper.toQuestionResponse(question);
            
            return ExamDetailResponse.ExamQuestionResponse.builder()
                    .id(eq.getId())
                    .questionId(question.getId())
                    .content(question.getContent())
                    .questionType(question.getQuestionType().toString())
                    .displayOrder(eq.getDisplayOrder())
                    .points(eq.getPoints())
                    .answers(questionResponse != null ? questionResponse.getAnswers() : null)
                    .build();
        } catch (Exception e) {
            // Log error but don't fail the entire request
            log.error("Error mapping exam question with id: {}", eq.getId(), e);
            return null;
        }
    }
}

