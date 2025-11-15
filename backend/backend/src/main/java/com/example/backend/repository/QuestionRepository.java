package com.example.backend.repository;

import com.example.backend.entity.Passage;
import com.example.backend.entity.Question;
import com.example.backend.enums.DifficultyLevel;
import com.example.backend.enums.QuestionType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Question entity
 */
@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    
    /**
     * Find all questions by passage
     */
    List<Question> findByPassage(Passage passage);
    
    /**
     * Find all active questions by passage
     */
    List<Question> findByPassageAndIsActive(Passage passage, Boolean isActive);
    
    /**
     * Find all questions by passage id
     */
    @Query("SELECT q FROM Question q JOIN FETCH q.passage WHERE q.passage.id = :passageId AND q.isActive = true ORDER BY q.displayOrder")
    List<Question> findByPassageId(@Param("passageId") Long passageId);
    
    /**
     * Find all questions by chapter id
     */
    @Query("SELECT q FROM Question q WHERE q.passage.chapter.id = :chapterId AND q.isActive = true")
    List<Question> findByChapterId(@Param("chapterId") Long chapterId);
    
    /**
     * Find all questions by subject id
     */
    @Query("SELECT q FROM Question q WHERE q.passage.chapter.subject.id = :subjectId AND q.isActive = true")
    List<Question> findBySubjectId(@Param("subjectId") Long subjectId);
    
    /**
     * Find questions by subject id with pagination
     */
    @Query("SELECT q FROM Question q WHERE q.passage.chapter.subject.id = :subjectId AND q.isActive = true")
    Page<Question> findBySubjectId(@Param("subjectId") Long subjectId, Pageable pageable);
    
    /**
     * Find questions by type
     */
    List<Question> findByQuestionTypeAndIsActive(QuestionType questionType, Boolean isActive);
    
    /**
     * Find questions by difficulty level
     */
    List<Question> findByDifficultyLevelAndIsActive(DifficultyLevel difficultyLevel, Boolean isActive);
    
    /**
     * Find questions by subject, type and difficulty
     */
    @Query("SELECT q FROM Question q WHERE q.passage.chapter.subject.id = :subjectId " +
           "AND q.questionType = :questionType AND q.difficultyLevel = :difficultyLevel AND q.isActive = true")
    List<Question> findBySubjectAndTypeAndDifficulty(@Param("subjectId") Long subjectId,
                                                      @Param("questionType") QuestionType questionType,
                                                      @Param("difficultyLevel") DifficultyLevel difficultyLevel);
    
    /**
     * Count questions by passage
     */
    long countByPassage(Passage passage);
    
    /**
     * Count questions by chapter id
     */
    @Query("SELECT COUNT(q) FROM Question q WHERE q.passage.chapter.id = :chapterId AND q.isActive = true")
    long countByChapterId(@Param("chapterId") Long chapterId);
    
    /**
     * Count questions by subject id
     */
    @Query("SELECT COUNT(q) FROM Question q WHERE q.passage.chapter.subject.id = :subjectId AND q.isActive = true")
    long countBySubjectId(@Param("subjectId") Long subjectId);
}

