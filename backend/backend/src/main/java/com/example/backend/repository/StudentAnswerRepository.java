package com.example.backend.repository;

import com.example.backend.entity.ExamSession;
import com.example.backend.entity.Question;
import com.example.backend.entity.StudentAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for StudentAnswer entity
 */
@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Long> {
    
    /**
     * Find all answers by exam session
     */
    List<StudentAnswer> findByExamSession(ExamSession examSession);
    
    /**
     * Find answer by exam session and question
     */
    Optional<StudentAnswer> findByExamSessionAndQuestion(ExamSession examSession, Question question);
    
    /**
     * Check if answer exists for question in session
     */
    boolean existsByExamSessionAndQuestion(ExamSession examSession, Question question);
    
    /**
     * Count answered questions in session
     */
    long countByExamSession(ExamSession examSession);
    
    /**
     * Count correct answers in session
     */
    @Query("SELECT COUNT(sa) FROM StudentAnswer sa WHERE sa.examSession = :examSession AND sa.isCorrect = true")
    long countCorrectAnswersBySession(@Param("examSession") ExamSession examSession);
    
    /**
     * Calculate total points earned in session
     */
    @Query("SELECT SUM(sa.pointsEarned) FROM StudentAnswer sa WHERE sa.examSession = :examSession")
    Double calculateTotalPointsBySession(@Param("examSession") ExamSession examSession);
    
    /**
     * Delete all answers by exam session
     */
    void deleteByExamSession(ExamSession examSession);
}

