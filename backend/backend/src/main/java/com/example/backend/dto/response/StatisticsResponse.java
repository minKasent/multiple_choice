package com.example.backend.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

/**
 * Statistics response DTOs
 */
public class StatisticsResponse {

    /**
     * Student statistics
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentStats {
        private Long studentId;
        private String studentName;
        private Integer totalExamsTaken;
        private Integer totalExamsPassed;
        private Integer totalExamsFailed;
        private BigDecimal averageScore;
        private BigDecimal highestScore;
        private BigDecimal lowestScore;
        private Integer totalViolations;
        private List<SubjectPerformance> subjectPerformances;
    }

    /**
     * Subject performance
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SubjectPerformance {
        private String subjectName;
        private Integer examsTaken;
        private BigDecimal averageScore;
    }

    /**
     * Exam statistics
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ExamStats {
        private Long examId;
        private String examTitle;
        private Integer totalSessions;
        private Integer completedSessions;
        private Integer passedSessions;
        private Double passRate;
        private BigDecimal averageScore;
        private BigDecimal highestScore;
        private BigDecimal lowestScore;
        private List<QuestionDifficulty> questionDifficulties;
    }

    /**
     * Question difficulty analysis
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuestionDifficulty {
        private Long questionId;
        private String content;
        private Integer totalAttempts;
        private Integer correctAttempts;
        private Double correctRate;
    }

    /**
     * Subject statistics
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SubjectStats {
        private Long subjectId;
        private String subjectName;
        private Integer totalChapters;
        private Integer totalQuestions;
        private Integer totalExams;
        private Integer totalSessions;
        private BigDecimal averageScore;
    }

    /**
     * Dashboard statistics
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class DashboardStats {
        private Integer totalUsers;
        private Integer totalStudents;
        private Integer totalTeachers;
        private Integer totalSubjects;
        private Integer totalQuestions;
        private Integer totalExams;
        private Integer totalSessions;
        private Integer completedSessions;
        private BigDecimal overallAverageScore;
        private Double overallPassRate;
    }
}

