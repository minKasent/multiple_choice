package com.example.backend.repository;

import com.example.backend.entity.Subject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Subject entity
 */
@Repository
public interface SubjectRepository extends JpaRepository<Subject, Long> {
    
    /**
     * Find subject by code
     */
    Optional<Subject> findByCode(String code);
    
    /**
     * Check if subject code exists
     */
    boolean existsByCode(String code);
    
    /**
     * Find all active subjects
     */
    List<Subject> findByIsActive(Boolean isActive);
    
    /**
     * Find all active subjects with pagination
     */
    Page<Subject> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * Search subjects by keyword (code, name)
     */
    @Query("SELECT s FROM Subject s WHERE s.isActive = true AND " +
           "(LOWER(s.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(s.name) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<Subject> searchSubjects(@Param("keyword") String keyword, Pageable pageable);
}

