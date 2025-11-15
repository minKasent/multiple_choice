package com.example.backend.repository;

import com.example.backend.entity.ExamRoom;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for ExamRoom entity
 */
@Repository
public interface ExamRoomRepository extends JpaRepository<ExamRoom, Long> {
    
    /**
     * Find exam room by code
     */
    Optional<ExamRoom> findByCode(String code);
    
    /**
     * Check if exam room code exists
     */
    boolean existsByCode(String code);
    
    /**
     * Find all active exam rooms
     */
    List<ExamRoom> findByIsActive(Boolean isActive);
    
    /**
     * Find all active exam rooms with pagination
     */
    Page<ExamRoom> findByIsActive(Boolean isActive, Pageable pageable);
    
    /**
     * Search exam rooms by keyword (name, code, location)
     */
    @Query("SELECT er FROM ExamRoom er WHERE er.isActive = true AND " +
           "(LOWER(er.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(er.code) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(er.location) LIKE LOWER(CONCAT('%', :keyword, '%')))")
    Page<ExamRoom> searchExamRooms(@Param("keyword") String keyword, Pageable pageable);
}

