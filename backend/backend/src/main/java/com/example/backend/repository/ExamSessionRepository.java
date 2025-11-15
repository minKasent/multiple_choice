package com.example.backend.repository;

import com.example.backend.entity.Exam;
import com.example.backend.entity.ExamSession;
import com.example.backend.entity.User;
import com.example.backend.enums.ExamSessionStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Repository interface for ExamSession entity
 */
@Repository
public interface ExamSessionRepository extends JpaRepository<ExamSession, Long> {
    
    /**
     * Find exam session by ID with relationships
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    Optional<ExamSession> findById(Long id);
    
    /**
     * Find exam session by session code
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    Optional<ExamSession> findBySessionCode(String sessionCode);
    
    /**
     * Find all sessions by exam
     */
    List<ExamSession> findByExam(Exam exam);
    
    /**
     * Find all sessions by student (only active exams)
     */
    @EntityGraph(attributePaths = {"exam", "exam.subject", "student"})
    @Query("SELECT es FROM ExamSession es WHERE es.student = :student AND es.exam.isActive = true")
    List<ExamSession> findByStudent(@Param("student") User student);
    
    /**
     * Find all sessions by student with pagination (only active exams)
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    @Query("SELECT es FROM ExamSession es WHERE es.student = :student AND es.exam.isActive = true")
    Page<ExamSession> findByStudent(@Param("student") User student, Pageable pageable);
    
    /**
     * Find sessions by exam and student
     */
    List<ExamSession> findByExamAndStudent(Exam exam, User student);
    
    /**
     * Find sessions by status
     */
    List<ExamSession> findByStatus(ExamSessionStatus status);
    
    /**
     * Find sessions by status with pagination
     */
    Page<ExamSession> findByStatus(ExamSessionStatus status, Pageable pageable);
    
    /**
     * Find sessions by student and status
     */
    List<ExamSession> findByStudentAndStatus(User student, ExamSessionStatus status);
    
    /**
     * Find active session for student and exam (only active exams)
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    @Query("SELECT es FROM ExamSession es WHERE es.student = :student AND es.exam = :exam " +
           "AND es.status IN ('SCHEDULED', 'IN_PROGRESS') AND es.exam.isActive = true")
    Optional<ExamSession> findActiveSessionByStudentAndExam(@Param("student") User student, @Param("exam") Exam exam);
    
    /**
     * Find upcoming sessions for student (only active exams)
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    @Query("SELECT es FROM ExamSession es WHERE es.student = :student AND es.status = 'SCHEDULED' " +
           "AND es.startTime > :now AND es.exam.isActive = true ORDER BY es.startTime")
    List<ExamSession> findUpcomingSessionsByStudent(@Param("student") User student, @Param("now") LocalDateTime now);
    
    /**
     * Find completed sessions for student (only active exams)
     */
    @EntityGraph(attributePaths = {"exam", "student"})
    @Query("SELECT es FROM ExamSession es WHERE es.student = :student AND es.status = 'COMPLETED' " +
           "AND es.exam.isActive = true ORDER BY es.actualEndTime DESC")
    Page<ExamSession> findCompletedSessionsByStudent(@Param("student") User student, Pageable pageable);
    
    /**
     * Count sessions by exam
     */
    long countByExam(Exam exam);
    
    /**
     * Count sessions by student
     */
    long countByStudent(User student);
    
    /**
     * Count sessions by status
     */
    long countByStatus(ExamSessionStatus status);
    
    /**
     * Find sessions by date range
     */
    @Query("SELECT es FROM ExamSession es WHERE es.startTime BETWEEN :startDate AND :endDate")
    List<ExamSession> findByDateRange(@Param("startDate") LocalDateTime startDate, 
                                      @Param("endDate") LocalDateTime endDate);
    
    /**
     * Get average score by exam
     */
    @Query("SELECT AVG(es.totalScore) FROM ExamSession es WHERE es.exam = :exam AND es.status = 'COMPLETED'")
    Double getAverageScoreByExam(@Param("exam") Exam exam);
    
    /**
     * Get pass rate by exam
     */
    @Query("SELECT COUNT(es) * 100.0 / (SELECT COUNT(es2) FROM ExamSession es2 WHERE es2.exam = :exam AND es2.status = 'COMPLETED') " +
           "FROM ExamSession es WHERE es.exam = :exam AND es.isPassed = true AND es.status = 'COMPLETED'")
    Double getPassRateByExam(@Param("exam") Exam exam);
}

