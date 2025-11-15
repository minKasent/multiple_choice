package com.example.backend.entity;

import com.example.backend.enums.DifficultyLevel;
import com.example.backend.enums.QuestionType;
import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing questions in the question bank
 */
@Entity
@Table(name = "question",
       indexes = {@Index(name = "idx_question_passage", columnList = "passage_id")})
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Question extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "passage_id", nullable = false)
    private Passage passage;

    @Enumerated(EnumType.STRING)
    @Column(name = "question_type", nullable = false, length = 50)
    private QuestionType questionType;

    @Column(name = "content", nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(name = "explanation", columnDefinition = "TEXT")
    private String explanation;

    @Enumerated(EnumType.STRING)
    @Column(name = "difficulty_level", length = 20)
    private DifficultyLevel difficultyLevel;

    @Column(name = "points", precision = 5, scale = 2)
    private BigDecimal points = BigDecimal.ONE;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Answer> answers = new ArrayList<>();

    /**
     * Add answer to question
     */
    public void addAnswer(Answer answer) {
        answers.add(answer);
        answer.setQuestion(this);
    }

    /**
     * Remove answer from question
     */
    public void removeAnswer(Answer answer) {
        answers.remove(answer);
        answer.setQuestion(null);
    }

    /**
     * Get correct answers
     */
    public List<Answer> getCorrectAnswers() {
        return answers.stream()
                .filter(Answer::getIsCorrect)
                .toList();
    }

    /**
     * Check if question has at least one correct answer
     */
    public boolean hasCorrectAnswer() {
        return answers.stream().anyMatch(Answer::getIsCorrect);
    }
}

