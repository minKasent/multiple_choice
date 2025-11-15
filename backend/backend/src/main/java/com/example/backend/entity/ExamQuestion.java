package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entity representing the many-to-many relationship between Exam and Question
 */
@Entity
@Table(name = "exam_question",
       indexes = {
           @Index(name = "idx_exam_question_exam", columnList = "exam_id"),
           @Index(name = "idx_exam_question_question", columnList = "question_id")
       },
       uniqueConstraints = {@UniqueConstraint(name = "uk_exam_question", columnNames = {"exam_id", "question_id"})})
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ExamQuestion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exam_id", nullable = false)
    private Exam exam;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "question_id", nullable = false)
    private Question question;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @Column(name = "points", nullable = false, precision = 5, scale = 2)
    private BigDecimal points;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}

