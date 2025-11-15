package com.example.backend.repository;

import com.example.backend.entity.Exam;
import com.example.backend.entity.ExamQuestion;
import com.example.backend.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for ExamQuestion entity
 */
@Repository
public interface ExamQuestionRepository extends JpaRepository<ExamQuestion, Long> {
    
    /**
     * Find all exam questions by exam
     */
    @Query("SELECT eq FROM ExamQuestion eq WHERE eq.exam = :exam ORDER BY eq.displayOrder")
    List<ExamQuestion> findByExam(@Param("exam") Exam exam);
    
    /**
     * Find all exam questions by exam id
     */
    @Query("SELECT eq FROM ExamQuestion eq WHERE eq.exam.id = :examId ORDER BY eq.displayOrder")
    List<ExamQuestion> findByExamId(@Param("examId") Long examId);
    
    /**
     * Find all exam questions by exam id with question eagerly loaded
     */
    @Query("SELECT eq FROM ExamQuestion eq LEFT JOIN FETCH eq.question WHERE eq.exam.id = :examId ORDER BY eq.displayOrder")
    List<ExamQuestion> findByExamIdWithQuestion(@Param("examId") Long examId);
    
    /**
     * Find exam question by exam and question
     */
    Optional<ExamQuestion> findByExamAndQuestion(Exam exam, Question question);
    
    /**
     * Check if question exists in exam
     */
    boolean existsByExamAndQuestion(Exam exam, Question question);
    
    /**
     * Count questions in exam
     */
    long countByExam(Exam exam);
    
    /**
     * Delete all questions from exam
     */
    void deleteByExam(Exam exam);
}

