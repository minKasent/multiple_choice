package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing chapters within a subject
 */
@Entity
@Table(name = "chapter", 
       indexes = {@Index(name = "idx_chapter_subject", columnList = "subject_id")},
       uniqueConstraints = {@UniqueConstraint(name = "uk_subject_chapter", columnNames = {"subject_id", "chapter_number"})})
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Chapter extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    @Column(name = "chapter_number", nullable = false)
    private Integer chapterNumber;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "display_order", nullable = false)
    private Integer displayOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "updated_by")
    private User updatedBy;

    @OneToMany(mappedBy = "chapter", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<Passage> passages = new ArrayList<>();

    /**
     * Add passage to chapter
     */
    public void addPassage(Passage passage) {
        passages.add(passage);
        passage.setChapter(this);
    }

    /**
     * Remove passage from chapter
     */
    public void removePassage(Passage passage) {
        passages.remove(passage);
        passage.setChapter(null);
    }
}

