package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Entity representing exam rooms (physical or virtual)
 */
@Entity
@Table(name = "exam_room")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class ExamRoom extends BaseEntity {

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "code", unique = true, nullable = false, length = 50)
    private String code;

    @Column(name = "location")
    private String location;

    @Column(name = "capacity")
    private Integer capacity;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private User createdBy;

    @OneToMany(mappedBy = "examRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ExamRoomProctor> proctors = new ArrayList<>();

    /**
     * Add proctor to exam room
     */
    public void addProctor(User proctor) {
        ExamRoomProctor examRoomProctor = ExamRoomProctor.builder()
                .examRoom(this)
                .proctor(proctor)
                .build();
        proctors.add(examRoomProctor);
    }

    /**
     * Remove proctor from exam room
     */
    public void removeProctor(User proctor) {
        proctors.removeIf(erp -> erp.getProctor().equals(proctor));
    }
}

