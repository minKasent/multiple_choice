package com.example.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import lombok.experimental.SuperBuilder;

/**
 * Entity representing user roles in the system
 */
@Entity
@Table(name = "role")
@Getter
@Setter
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class Role extends BaseEntity {

    @Column(name = "name", unique = true, nullable = false, length = 50)
    private String name;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    // Role constants
    public static final String ADMIN = "ADMIN";
    public static final String TEACHER = "TEACHER";
    public static final String PROCTOR = "PROCTOR";
    public static final String STUDENT = "STUDENT";
}

