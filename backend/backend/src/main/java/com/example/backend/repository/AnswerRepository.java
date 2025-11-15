package com.example.backend.repository;

import com.example.backend.entity.Answer;
import com.example.backend.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Answer entity
 */
@Repository
public interface AnswerRepository extends JpaRepository<Answer, Long> {
    
    /**
     * Find all answers by question
     */
    List<Answer> findByQuestion(Question question);
    
    /**
     * Find all active answers by question
     */
    List<Answer> findByQuestionAndIsActive(Question question, Boolean isActive);
    
    /**
     * Find all answers by question id
     */
    @Query("SELECT a FROM Answer a WHERE a.question.id = :questionId AND a.isActive = true ORDER BY a.displayOrder")
    List<Answer> findByQuestionId(@Param("questionId") Long questionId);
    
    /**
     * Find correct answers by question
     */
    @Query("SELECT a FROM Answer a WHERE a.question = :question AND a.isCorrect = true AND a.isActive = true")
    List<Answer> findCorrectAnswersByQuestion(@Param("question") Question question);
    
    /**
     * Count answers by question
     */
    long countByQuestion(Question question);
    
    /**
     * Count correct answers by question
     */
    @Query("SELECT COUNT(a) FROM Answer a WHERE a.question = :question AND a.isCorrect = true AND a.isActive = true")
    long countCorrectAnswersByQuestion(@Param("question") Question question);
}

