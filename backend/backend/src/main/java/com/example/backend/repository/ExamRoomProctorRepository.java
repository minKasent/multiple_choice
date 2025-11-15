package com.example.backend.repository;

import com.example.backend.entity.ExamRoom;
import com.example.backend.entity.ExamRoomProctor;
import com.example.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for ExamRoomProctor entity
 */
@Repository
public interface ExamRoomProctorRepository extends JpaRepository<ExamRoomProctor, Long> {
    
    /**
     * Find all proctors by exam room
     */
    List<ExamRoomProctor> findByExamRoom(ExamRoom examRoom);
    
    /**
     * Find all proctors by exam room ID
     */
    List<ExamRoomProctor> findByExamRoomId(Long examRoomId);
    
    /**
     * Find all exam rooms by proctor
     */
    List<ExamRoomProctor> findByProctor(User proctor);
    
    /**
     * Find specific exam room proctor assignment
     */
    Optional<ExamRoomProctor> findByExamRoomAndProctor(ExamRoom examRoom, User proctor);
    
    /**
     * Check if proctor is assigned to exam room
     */
    boolean existsByExamRoomAndProctor(ExamRoom examRoom, User proctor);
    
    /**
     * Delete assignment
     */
    void deleteByExamRoomAndProctor(ExamRoom examRoom, User proctor);
    
    /**
     * Delete all proctors by exam room ID
     */
    void deleteByExamRoomId(Long examRoomId);
    
    /**
     * Delete proctor by exam room ID and proctor ID
     */
    void deleteByExamRoomIdAndProctorId(Long examRoomId, Long proctorId);
}

