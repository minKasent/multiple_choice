package com.example.backend.repository;

import com.example.backend.entity.Chapter;
import com.example.backend.entity.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Chapter entity
 */
@Repository
public interface ChapterRepository extends JpaRepository<Chapter, Long> {
    
    /**
     * Find all chapters by subject
     */
    List<Chapter> findBySubject(Subject subject);
    
    /**
     * Find all active chapters by subject
     */
    List<Chapter> findBySubjectAndIsActive(Subject subject, Boolean isActive);
    
    /**
     * Find all chapters by subject id
     */
    @Query("SELECT c FROM Chapter c JOIN FETCH c.subject WHERE c.subject.id = :subjectId AND c.isActive = true ORDER BY c.displayOrder")
    List<Chapter> findBySubjectId(@Param("subjectId") Long subjectId);
    
    /**
     * Find chapter by subject and chapter number
     */
    Optional<Chapter> findBySubjectAndChapterNumber(Subject subject, Integer chapterNumber);
    
    /**
     * Check if chapter exists by subject and chapter number
     */
    boolean existsBySubjectAndChapterNumber(Subject subject, Integer chapterNumber);
    
    /**
     * Count chapters by subject
     */
    long countBySubject(Subject subject);
}

