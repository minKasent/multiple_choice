package com.example.backend.entity;

import com.example.backend.enums.ExamSessionStatus;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Entity representing actual exam instances taken by students
 */
@Entity
@Table(name = "exam_session",
       indexes = {
           @Index(name = "idx_exam_session_exam", columnList = "exam_id"),
           @Index(name = "idx_exam_session_student", columnList = "student_id"),
           @Index(name = "idx_exam_session_status", columnList = "status"),
           @Index(name = "idx_exam_session_start_time", columnList = "start_time")
       })
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class ExamSession extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_id", nullable = false)
    private Exam exam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_room_id")
    private ExamRoom examRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @Column(name = "session_code", unique = true, nullable = false, length = 100)
    private String sessionCode;

    @Column(name = "start_time", nullable = false)
    private LocalDateTime startTime;

    @Column(name = "end_time", nullable = false)
    private LocalDateTime endTime;

    @Column(name = "actual_start_time")
    private LocalDateTime actualStartTime;

    @Column(name = "actual_end_time")
    private LocalDateTime actualEndTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 50)
    private ExamSessionStatus status = ExamSessionStatus.SCHEDULED;

    @Column(name = "total_score", precision = 5, scale = 2)
    private BigDecimal totalScore;

    @Column(name = "percentage_score", precision = 5, scale = 2)
    private BigDecimal percentageScore;

    @Column(name = "is_passed")
    private Boolean isPassed;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "questions_data", columnDefinition = "jsonb")
    private Map<String, Object> questionsData;

    @Column(name = "ip_address", length = 50)
    private String ipAddress;

    @Column(name = "browser_info", columnDefinition = "TEXT")
    private String browserInfo;

    @Column(name = "violation_count")
    private Integer violationCount = 0;

    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes;

    @Column(name = "graded_at")
    private LocalDateTime gradedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "graded_by")
    private User gradedBy;

    @OneToMany(mappedBy = "examSession", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<StudentAnswer> studentAnswers = new ArrayList<>();

    /**
     * Add student answer
     */
    public void addAnswer(StudentAnswer answer) {
        studentAnswers.add(answer);
        answer.setExamSession(this);
    }

    /**
     * Check if session is in progress
     */
    public boolean isInProgress() {
        return status == ExamSessionStatus.IN_PROGRESS;
    }

    /**
     * Check if session is completed
     */
    public boolean isCompleted() {
        return status == ExamSessionStatus.COMPLETED;
    }

    /**
     * Check if session can be started
     */
    public boolean canStart() {
        return status == ExamSessionStatus.SCHEDULED 
               && LocalDateTime.now().isAfter(startTime);
    }

    /**
     * Start the exam session
     */
    public void start() {
        this.status = ExamSessionStatus.IN_PROGRESS;
        this.actualStartTime = LocalDateTime.now();
    }

    /**
     * Complete the exam session
     */
    public void complete() {
        this.status = ExamSessionStatus.COMPLETED;
        this.actualEndTime = LocalDateTime.now();
    }

    /**
     * Increment violation count
     */
    public void incrementViolation() {
        if (this.violationCount == null) {
            this.violationCount = 0;
        }
        this.violationCount++;
    }
}

