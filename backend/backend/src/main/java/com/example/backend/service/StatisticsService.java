package com.example.backend.service;

import com.example.backend.dto.response.StatisticsResponse;
import com.example.backend.entity.Exam;
import com.example.backend.entity.ExamSession;
import com.example.backend.entity.User;
import com.example.backend.enums.ExamSessionStatus;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.*;
import com.example.backend.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service for statistics and analytics
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class StatisticsService {

    private final UserRepository userRepository;
    private final SubjectRepository subjectRepository;
    private final QuestionRepository questionRepository;
    private final ExamRepository examRepository;
    private final ExamSessionRepository examSessionRepository;
    private final StudentAnswerRepository studentAnswerRepository;

    /**
     * Get student statistics
     */
    @Transactional(readOnly = true)
    public StatisticsResponse.StudentStats getStudentStatistics(Long studentId) {
        log.info("Getting statistics for student: {}", studentId);

        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", studentId));

        List<ExamSession> sessions = examSessionRepository.findByStudent(student);
        
        List<ExamSession> completedSessions = sessions.stream()
                .filter(s -> s.getStatus() == ExamSessionStatus.COMPLETED)
                .toList();

        if (completedSessions.isEmpty()) {
            return StatisticsResponse.StudentStats.builder()
                    .studentId(studentId)
                    .studentName(student.getFullName())
                    .totalExamsTaken(0)
                    .totalExamsPassed(0)
                    .totalExamsFailed(0)
                    .averageScore(BigDecimal.ZERO)
                    .highestScore(BigDecimal.ZERO)
                    .lowestScore(BigDecimal.ZERO)
                    .totalViolations(0)
                    .subjectPerformances(new ArrayList<>())
                    .build();
        }

        int totalPassed = (int) completedSessions.stream()
                .filter(s -> s.getIsPassed() != null && s.getIsPassed())
                .count();

        // Filter out sessions with null percentageScore
        List<ExamSession> sessionsWithScore = completedSessions.stream()
                .filter(s -> s.getPercentageScore() != null)
                .toList();

        BigDecimal totalScore = BigDecimal.ZERO;
        BigDecimal averageScore = BigDecimal.ZERO;
        BigDecimal highestScore = BigDecimal.ZERO;
        BigDecimal lowestScore = BigDecimal.ZERO;

        if (!sessionsWithScore.isEmpty()) {
            totalScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            averageScore = totalScore.divide(
                    BigDecimal.valueOf(sessionsWithScore.size()), 
                    2, 
                    RoundingMode.HALF_UP
            );

            highestScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .max(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);

            lowestScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .min(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
        }

        int totalViolations = completedSessions.stream()
                .mapToInt(s -> s.getViolationCount() != null ? s.getViolationCount() : 0)
                .sum();

        // Subject performances
        Map<String, List<ExamSession>> sessionsBySubject = completedSessions.stream()
                .filter(s -> s.getExam() != null && s.getExam().getSubject() != null)
                .collect(Collectors.groupingBy(s -> s.getExam().getSubject().getName()));

        List<StatisticsResponse.SubjectPerformance> subjectPerformances = sessionsBySubject.entrySet().stream()
                .map(entry -> {
                    String subjectName = entry.getKey();
                    List<ExamSession> subjectSessions = entry.getValue();
                    
                    // Filter out sessions with null percentageScore
                    List<ExamSession> subjectSessionsWithScore = subjectSessions.stream()
                            .filter(s -> s.getPercentageScore() != null)
                            .toList();
                    
                    BigDecimal subjectAvg = BigDecimal.ZERO;
                    if (!subjectSessionsWithScore.isEmpty()) {
                        BigDecimal subjectTotal = subjectSessionsWithScore.stream()
                                .map(ExamSession::getPercentageScore)
                                .reduce(BigDecimal.ZERO, BigDecimal::add);
                        
                        subjectAvg = subjectTotal.divide(
                                BigDecimal.valueOf(subjectSessionsWithScore.size()),
                                2,
                                RoundingMode.HALF_UP
                        );
                    }

                    return StatisticsResponse.SubjectPerformance.builder()
                            .subjectName(subjectName)
                            .examsTaken(subjectSessions.size())
                            .averageScore(subjectAvg)
                            .build();
                })
                .collect(Collectors.toList());

        return StatisticsResponse.StudentStats.builder()
                .studentId(studentId)
                .studentName(student.getFullName())
                .totalExamsTaken(completedSessions.size())
                .totalExamsPassed(totalPassed)
                .totalExamsFailed(completedSessions.size() - totalPassed)
                .averageScore(averageScore)
                .highestScore(highestScore)
                .lowestScore(lowestScore)
                .totalViolations(totalViolations)
                .subjectPerformances(subjectPerformances)
                .build();
    }

    /**
     * Get exam statistics
     */
    @Transactional(readOnly = true)
    public StatisticsResponse.ExamStats getExamStatistics(Long examId) {
        log.info("Getting statistics for exam: {}", examId);

        Exam exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", examId));

        List<ExamSession> sessions = examSessionRepository.findByExam(exam);
        
        long completedCount = sessions.stream()
                .filter(s -> s.getStatus() == ExamSessionStatus.COMPLETED)
                .count();

        List<ExamSession> completedSessions = sessions.stream()
                .filter(s -> s.getStatus() == ExamSessionStatus.COMPLETED)
                .toList();

        if (completedSessions.isEmpty()) {
            return StatisticsResponse.ExamStats.builder()
                    .examId(examId)
                    .examTitle(exam.getTitle())
                    .totalSessions(sessions.size())
                    .completedSessions(0)
                    .passedSessions(0)
                    .passRate(0.0)
                    .averageScore(BigDecimal.ZERO)
                    .questionDifficulties(new ArrayList<>())
                    .build();
        }

        long passedCount = completedSessions.stream()
                .filter(s -> s.getIsPassed() != null && s.getIsPassed())
                .count();

        double passRate = completedCount > 0 ? (passedCount * 100.0) / completedCount : 0.0;

        // Filter out sessions with null percentageScore
        List<ExamSession> sessionsWithScore = completedSessions.stream()
                .filter(s -> s.getPercentageScore() != null)
                .toList();

        BigDecimal totalScore = BigDecimal.ZERO;
        BigDecimal averageScore = BigDecimal.ZERO;
        BigDecimal highestScore = BigDecimal.ZERO;
        BigDecimal lowestScore = BigDecimal.ZERO;

        if (!sessionsWithScore.isEmpty()) {
            totalScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            averageScore = totalScore.divide(
                    BigDecimal.valueOf(sessionsWithScore.size()),
                    2,
                    RoundingMode.HALF_UP
            );

            highestScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .max(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);

            lowestScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .min(BigDecimal::compareTo)
                    .orElse(BigDecimal.ZERO);
        }

        return StatisticsResponse.ExamStats.builder()
                .examId(examId)
                .examTitle(exam.getTitle())
                .totalSessions(sessions.size())
                .completedSessions((int) completedCount)
                .passedSessions((int) passedCount)
                .passRate(passRate)
                .averageScore(averageScore)
                .highestScore(highestScore)
                .lowestScore(lowestScore)
                .questionDifficulties(new ArrayList<>())
                .build();
    }

    /**
     * Get subject statistics
     */
    @Transactional(readOnly = true)
    public StatisticsResponse.SubjectStats getSubjectStatistics(Long subjectId) {
        log.info("Getting statistics for subject: {}", subjectId);

        var subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", subjectId));

        long totalChapters = questionRepository.countBySubjectId(subjectId);
        long totalQuestions = questionRepository.countBySubjectId(subjectId);
        long totalExams = examRepository.countBySubject(subject);

        List<Exam> subjectExams = examRepository.findBySubjectId(subjectId);
        List<ExamSession> allSessions = subjectExams.stream()
                .flatMap(exam -> examSessionRepository.findByExam(exam).stream())
                .toList();

        List<ExamSession> completedSessions = allSessions.stream()
                .filter(s -> s.getStatus() == ExamSessionStatus.COMPLETED)
                .toList();

        BigDecimal averageScore = BigDecimal.ZERO;
        List<ExamSession> sessionsWithScore = completedSessions.stream()
                .filter(s -> s.getPercentageScore() != null)
                .toList();
        
        if (!sessionsWithScore.isEmpty()) {
            BigDecimal totalScore = sessionsWithScore.stream()
                    .map(ExamSession::getPercentageScore)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            averageScore = totalScore.divide(
                    BigDecimal.valueOf(sessionsWithScore.size()),
                    2,
                    RoundingMode.HALF_UP
            );
        }

        return StatisticsResponse.SubjectStats.builder()
                .subjectId(subjectId)
                .subjectName(subject.getName())
                .totalChapters((int) totalChapters)
                .totalQuestions((int) totalQuestions)
                .totalExams((int) totalExams)
                .totalSessions(allSessions.size())
                .averageScore(averageScore)
                .build();
    }

    /**
     * Get dashboard statistics
     */
    @Transactional(readOnly = true)
    public StatisticsResponse.DashboardStats getDashboardStatistics() {
        log.info("Getting dashboard statistics");

        long totalUsers = userRepository.count();
        long totalStudents = userRepository.findByRoleName("STUDENT").size();
        long totalTeachers = userRepository.findByRoleName("TEACHER").size();
        long totalSubjects = subjectRepository.count();
        long totalQuestions = questionRepository.count();
        long totalExams = examRepository.count();
        long totalSessions = examSessionRepository.count();
        long completedSessions = examSessionRepository.countByStatus(ExamSessionStatus.COMPLETED);

        List<ExamSession> allCompletedSessions = examSessionRepository.findByStatus(ExamSessionStatus.COMPLETED);

        BigDecimal overallAverageScore = BigDecimal.ZERO;
        Double overallPassRate = 0.0;

        if (!allCompletedSessions.isEmpty()) {
            // Filter out sessions with null percentageScore
            List<ExamSession> sessionsWithScore = allCompletedSessions.stream()
                    .filter(s -> s.getPercentageScore() != null)
                    .toList();

            if (!sessionsWithScore.isEmpty()) {
                BigDecimal totalScore = sessionsWithScore.stream()
                        .map(ExamSession::getPercentageScore)
                        .reduce(BigDecimal.ZERO, BigDecimal::add);

                overallAverageScore = totalScore.divide(
                        BigDecimal.valueOf(sessionsWithScore.size()),
                        2,
                        RoundingMode.HALF_UP
                );
            }

            long passedCount = allCompletedSessions.stream()
                    .filter(s -> s.getIsPassed() != null && s.getIsPassed())
                    .count();

            overallPassRate = (passedCount * 100.0) / allCompletedSessions.size();
        }

        return StatisticsResponse.DashboardStats.builder()
                .totalUsers((int) totalUsers)
                .totalStudents((int) totalStudents)
                .totalTeachers((int) totalTeachers)
                .totalSubjects((int) totalSubjects)
                .totalQuestions((int) totalQuestions)
                .totalExams((int) totalExams)
                .totalSessions((int) totalSessions)
                .completedSessions((int) completedSessions)
                .overallAverageScore(overallAverageScore)
                .overallPassRate(overallPassRate)
                .build();
    }

    /**
     * Get current user's statistics
     */
    public StatisticsResponse.StudentStats getMyStatistics() {
        User currentUser = getCurrentUser();
        return getStudentStatistics(currentUser.getId());
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Current user not found"));
    }
}

