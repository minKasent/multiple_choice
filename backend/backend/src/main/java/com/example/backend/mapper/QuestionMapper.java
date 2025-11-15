package com.example.backend.mapper;

import com.example.backend.dto.response.ChapterResponse;
import com.example.backend.dto.response.PassageResponse;
import com.example.backend.dto.response.QuestionResponse;
import com.example.backend.entity.Answer;
import com.example.backend.entity.Chapter;
import com.example.backend.entity.Passage;
import com.example.backend.entity.Question;
import com.example.backend.repository.PassageRepository;
import com.example.backend.repository.QuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

/**
 * Mapper for Question bank entities to DTOs
 */
@Component
@RequiredArgsConstructor
public class QuestionMapper {
    
    private final PassageRepository passageRepository;
    private final QuestionRepository questionRepository;
    
    public ChapterResponse toChapterResponse(Chapter chapter) {
        if (chapter == null) {
            return null;
        }
        
        return ChapterResponse.builder()
                .id(chapter.getId())
                .subjectId(chapter.getSubject().getId())
                .subjectName(chapter.getSubject().getName())
                .chapterNumber(chapter.getChapterNumber())
                .title(chapter.getTitle())
                .description(chapter.getDescription())
                .displayOrder(chapter.getDisplayOrder())
                .isActive(chapter.getIsActive())
                .passageCount(passageRepository.countByChapter(chapter))
                .questionCount(questionRepository.countByChapterId(chapter.getId()))
                .createdAt(chapter.getCreatedAt())
                .updatedAt(chapter.getUpdatedAt())
                .build();
    }
    
    public PassageResponse toPassageResponse(Passage passage) {
        if (passage == null) {
            return null;
        }
        
        return PassageResponse.builder()
                .id(passage.getId())
                .chapterId(passage.getChapter().getId())
                .chapterTitle(passage.getChapter().getTitle())
                .title(passage.getTitle())
                .content(passage.getContent())
                .displayOrder(passage.getDisplayOrder())
                .isActive(passage.getIsActive())
                .questionCount(questionRepository.countByPassage(passage))
                .createdAt(passage.getCreatedAt())
                .build();
    }
    
    public QuestionResponse toQuestionResponse(Question question) {
        if (question == null) {
            return null;
        }
        
        return QuestionResponse.builder()
                .id(question.getId())
                .passageId(question.getPassage().getId())
                .questionType(question.getQuestionType())
                .content(question.getContent())
                .explanation(question.getExplanation())
                .difficultyLevel(question.getDifficultyLevel())
                .points(question.getPoints())
                .displayOrder(question.getDisplayOrder())
                .isActive(question.getIsActive())
                .answers(question.getAnswers().stream()
                        .map(this::toAnswerResponse)
                        .collect(Collectors.toList()))
                .createdAt(question.getCreatedAt())
                .build();
    }
    
    private QuestionResponse.AnswerResponse toAnswerResponse(Answer answer) {
        if (answer == null) {
            return null;
        }
        
        return QuestionResponse.AnswerResponse.builder()
                .id(answer.getId())
                .content(answer.getContent())
                .isCorrect(answer.getIsCorrect())
                .displayOrder(answer.getDisplayOrder())
                .build();
    }
}

