package com.example.backend.repository;

import com.example.backend.entity.Exam;
import com.example.backend.entity.Subject;
import com.example.backend.enums.ExamType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Exam entity
 */
@Repository
public interface ExamRepository extends JpaRepository<Exam, Long> {
    
    /**
     * Find all exams by subject
     */
    List<Exam> findBySubject(Subject subject);
    
    /**
     * Find all active exams by subject
     */
    List<Exam> findBySubjectAndIsActive(Subject subject, Boolean isActive);
    
    /**
     * Find all exams by subject id
     */
    @Query("SELECT e FROM Exam e WHERE e.subject.id = :subjectId AND e.isActive = true")
    List<Exam> findBySubjectId(@Param("subjectId") Long subjectId);
    
    /**
     * Find all exams by subject id with pagination
     */
    @EntityGraph(attributePaths = {"subject", "createdBy"})
    @Query("SELECT e FROM Exam e WHERE e.subject.id = :subjectId AND e.isActive = true")
    Page<Exam> findBySubjectId(@Param("subjectId") Long subjectId, Pageable pageable);
    
    /**
     * Find exams by type
     */
    List<Exam> findByExamTypeAndIsActive(ExamType examType, Boolean isActive);
    
    /**
     * Find exams by subject and type
     */
    @Query("SELECT e FROM Exam e WHERE e.subject.id = :subjectId AND e.examType = :examType AND e.isActive = true")
    List<Exam> findBySubjectIdAndExamType(@Param("subjectId") Long subjectId, @Param("examType") ExamType examType);
    
    /**
     * Find all active exams
     */
    List<Exam> findByIsActive(Boolean isActive);
    
    /**
     * Find all active exams with pagination
     */
    @EntityGraph(attributePaths = {"subject", "createdBy"})
    Page<Exam> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * Search exams by keyword (title, description)
     */
    @EntityGraph(attributePaths = {"subject", "createdBy"})
    @Query("SELECT e FROM Exam e WHERE e.isActive = true AND " +
           "(LOWER(e.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(e.description) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Exam> searchExams(@Param("keyword") String keyword, Pageable pageable);
    
    /**
     * Count exams by subject
     */
    long countBySubject(Subject subject);
    
    /**
     * Find exam by id with subject and createdBy eagerly loaded
     */
    @Query("SELECT e FROM Exam e LEFT JOIN FETCH e.subject LEFT JOIN FETCH e.createdBy WHERE e.id = :id")
    java.util.Optional<Exam> findByIdWithSubject(@Param("id") Long id);
}

