package com.example.backend.entity;

import com.example.backend.enums.ExamType;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing exam templates
 */
@Entity
@Table(name = "exam",
       indexes = {@Index(name = "idx_exam_subject", columnList = "subject_id")})
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Exam extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "duration_minutes", nullable = false)
    private Integer durationMinutes;

    @Column(name = "total_questions", nullable = false)
    private Integer totalQuestions;

    @Column(name = "total_points", nullable = false, precision = 5, scale = 2)
    private BigDecimal totalPoints;

    @Column(name = "passing_score", nullable = false, precision = 5, scale = 2)
    private BigDecimal passingScore;

    @Enumerated(EnumType.STRING)
    @Column(name = "exam_type", length = 50)
    private ExamType examType;

    @Column(name = "is_shuffled")
    private Boolean isShuffled = true;

    @Column(name = "is_shuffle_answers")
    private Boolean isShuffleAnswers = true;

    @Column(name = "show_result_immediately")
    private Boolean showResultImmediately = false;

    @Column(name = "allow_review")
    private Boolean allowReview = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    @OneToMany(mappedBy = "exam", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ExamQuestion> examQuestions = new ArrayList<>();

    /**
     * Add question to exam
     */
    public void addQuestion(ExamQuestion examQuestion) {
        examQuestions.add(examQuestion);
        examQuestion.setExam(this);
    }

    /**
     * Remove question from exam
     */
    public void removeQuestion(ExamQuestion examQuestion) {
        examQuestions.remove(examQuestion);
        examQuestion.setExam(null);
    }

    /**
     * Calculate total points from questions
     */
    public BigDecimal calculateTotalPoints() {
        return examQuestions.stream()
                .map(ExamQuestion::getPoints)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

