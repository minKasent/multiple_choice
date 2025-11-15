package com.example.backend.repository;

import com.example.backend.entity.Chapter;
import com.example.backend.entity.Passage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository interface for Passage entity
 */
@Repository
public interface PassageRepository extends JpaRepository<Passage, Long> {
    
    /**
     * Find all passages by chapter
     */
    List<Passage> findByChapter(Chapter chapter);
    
    /**
     * Find all active passages by chapter
     */
    List<Passage> findByChapterAndIsActive(Chapter chapter, Boolean isActive);
    
    /**
     * Find all passages by chapter id
     */
    @Query("SELECT p FROM Passage p JOIN FETCH p.chapter WHERE p.chapter.id = :chapterId AND p.isActive = true ORDER BY p.displayOrder")
    List<Passage> findByChapterId(@Param("chapterId") Long chapterId);
    
    /**
     * Find all passages by subject id
     */
    @Query("SELECT p FROM Passage p WHERE p.chapter.subject.id = :subjectId AND p.isActive = true")
    List<Passage> findBySubjectId(@Param("subjectId") Long subjectId);
    
    /**
     * Count passages by chapter
     */
    long countByChapter(Chapter chapter);
}

