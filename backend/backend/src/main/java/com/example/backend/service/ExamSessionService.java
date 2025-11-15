package com.example.backend.service;

import com.example.backend.dto.request.ScheduleExamRequest;
import com.example.backend.dto.request.SubmitAnswerRequest;
import com.example.backend.dto.response.*;
import com.example.backend.entity.*;
import com.example.backend.enums.ExamSessionStatus;
import com.example.backend.enums.QuestionType;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ForbiddenException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.repository.*;
import com.example.backend.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Service for exam session management and taking exams
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ExamSessionService {

    private final ExamSessionRepository examSessionRepository;
    private final ExamRepository examRepository;
    private final UserRepository userRepository;
    private final ExamRoomRepository examRoomRepository;
    private final ExamQuestionRepository examQuestionRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final AnswerRepository answerRepository;
    private final QuestionRepository questionRepository;
    private final GradingService gradingService;

    /**
     * Schedule exam sessions for students
     */
    @Transactional
    public List<ExamSessionResponse> scheduleExam(ScheduleExamRequest request) {
        log.info("Scheduling exam: {}", request.getExamId());

        Exam exam = examRepository.findById(request.getExamId())
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", request.getExamId()));

        ExamRoom examRoom = null;
        if (request.getExamRoomId() != null) {
            examRoom = examRoomRepository.findById(request.getExamRoomId())
                    .orElseThrow(() -> new ResourceNotFoundException("ExamRoom", "id", request.getExamRoomId()));
        }

        LocalDateTime startTime = request.getStartTime();
        LocalDateTime endTime = startTime.plusMinutes(exam.getDurationMinutes());

        List<ExamSessionResponse> scheduledSessions = new ArrayList<>();

        for (Long studentId : request.getStudentIds()) {
            User student = userRepository.findById(studentId)
                    .orElseThrow(() -> new ResourceNotFoundException("User", "id", studentId));

            if (!student.isStudent()) {
                throw new BadRequestException("User is not a student: " + studentId);
            }

            String sessionCode = generateSessionCode();

            ExamSession session = ExamSession.builder()
                    .exam(exam)
                    .examRoom(examRoom)
                    .student(student)
                    .sessionCode(sessionCode)
                    .startTime(startTime)
                    .endTime(endTime)
                    .status(ExamSessionStatus.SCHEDULED)
                    .violationCount(0)
                    .build();

            ExamSession savedSession = examSessionRepository.save(session);
            scheduledSessions.add(toExamSessionResponse(savedSession));
        }

        log.info("Scheduled {} exam sessions", scheduledSessions.size());
        return scheduledSessions;
    }

    /**
     * Get student's exams
     */
    public Page<ExamSessionResponse> getMyExams(Pageable pageable) {
        User currentUser = getCurrentUser();
        return examSessionRepository.findByStudent(currentUser, pageable)
                .map(this::toExamSessionResponse);
    }

    /**
     * Get exam session by ID
     */
    public ExamSessionResponse getExamSession(Long sessionId) {
        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));
        
        // Check permission
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin() && !currentUser.isTeacher() && !currentUser.isProctor()) {
            if (!session.getStudent().getId().equals(currentUser.getId())) {
                throw new ForbiddenException("You don't have permission to view this exam session");
            }
        }
        
        return toExamSessionResponse(session);
    }

    /**
     * Start exam
     */
    @Transactional
    public TakeExamResponse startExam(Long sessionId) {
        log.info("Starting exam session: {}", sessionId);

        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));

        // Verify student
        User currentUser = getCurrentUser();
        if (!session.getStudent().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("This exam session is not assigned to you");
        }

        // If exam is already in progress, check if time has expired
        if (session.getStatus() == ExamSessionStatus.IN_PROGRESS) {
            LocalDateTime now = LocalDateTime.now();
            if (now.isAfter(session.getEndTime())) {
                // Time expired, auto-complete the exam
                log.info("Exam session time expired, auto-completing: {}", sessionId);
                completeExam(sessionId);
                throw new BadRequestException("Exam time has expired");
            }
            log.info("Exam session already in progress, returning exam data: {}", sessionId);
            return buildTakeExamResponse(session);
        }

        // Check if already completed
        if (session.getStatus() == ExamSessionStatus.COMPLETED) {
            throw new BadRequestException("Exam already completed");
        }

        // Check if cancelled or missed
        if (session.getStatus() == ExamSessionStatus.CANCELLED) {
            throw new BadRequestException("Exam has been cancelled");
        }

        if (session.getStatus() == ExamSessionStatus.MISSED) {
            throw new BadRequestException("Exam time has passed");
        }

        LocalDateTime now = LocalDateTime.now();
        if (now.isBefore(session.getStartTime())) {
            throw new BadRequestException("Exam has not started yet");
        }

        if (now.isAfter(session.getEndTime())) {
            session.setStatus(ExamSessionStatus.MISSED);
            examSessionRepository.save(session);
            throw new BadRequestException("Exam time has passed");
        }

        // Start exam
        session.setActualStartTime(now);
        session.setStatus(ExamSessionStatus.IN_PROGRESS);
        examSessionRepository.save(session);

        log.info("Exam session started: {}", sessionId);
        return buildTakeExamResponse(session);
    }

    /**
     * Submit answer
     */
    @Transactional
    public void submitAnswer(Long sessionId, SubmitAnswerRequest request) {
        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));

        // Verify student
        User currentUser = getCurrentUser();
        if (!session.getStudent().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("This exam session is not assigned to you");
        }

        // Check if time expired - auto complete if expired
        LocalDateTime now = LocalDateTime.now();
        if (now.isAfter(session.getEndTime())) {
            if (session.getStatus() == ExamSessionStatus.IN_PROGRESS) {
                log.info("Exam time expired, auto-completing exam session: {}", sessionId);
                completeExam(sessionId);
                // Reload session to get updated status
                session = examSessionRepository.findById(sessionId)
                        .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));
            }
            // After auto-complete, don't allow saving new answers
            if (session.getStatus() == ExamSessionStatus.COMPLETED) {
                throw new BadRequestException("Exam time has expired");
            }
        } else if (session.getStatus() != ExamSessionStatus.IN_PROGRESS) {
            throw new BadRequestException("Exam is not in progress");
        }

        Question question = questionRepository.findById(request.getQuestionId())
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", request.getQuestionId()));

        // Check if answer already exists
        StudentAnswer existingAnswer = studentAnswerRepository
                .findByExamSessionAndQuestion(session, question)
                .orElse(null);

        // Get answer ID from answerIds (first element) or answerId
        final Long answerIdToUse;
        if (request.getAnswerIds() != null && !request.getAnswerIds().isEmpty()) {
            answerIdToUse = request.getAnswerIds().get(0); // Use first answer ID
        } else if (request.getAnswerId() != null) {
            answerIdToUse = request.getAnswerId();
        } else {
            answerIdToUse = null;
        }

        if (existingAnswer != null) {
            // Update existing answer
            if (question.getQuestionType() == QuestionType.MULTIPLE_CHOICE || 
                question.getQuestionType() == QuestionType.TRUE_FALSE) {
                if (answerIdToUse == null) {
                    throw new BadRequestException("Answer ID is required for multiple choice or true/false questions");
                }
                Answer answer = answerRepository.findById(answerIdToUse)
                        .orElseThrow(() -> new ResourceNotFoundException("Answer", "id", answerIdToUse));
                existingAnswer.setAnswer(answer);
            } else if (question.getQuestionType() == QuestionType.FILL_IN_BLANK) {
                existingAnswer.setAnswerText(request.getAnswerText());
            }
            existingAnswer.setTimeSpentSeconds(request.getTimeSpentSeconds());
            studentAnswerRepository.save(existingAnswer);
        } else {
            // Create new answer
            StudentAnswer.StudentAnswerBuilder builder = StudentAnswer.builder()
                    .examSession(session)
                    .question(question)
                    .timeSpentSeconds(request.getTimeSpentSeconds());

            if (question.getQuestionType() == QuestionType.MULTIPLE_CHOICE || 
                question.getQuestionType() == QuestionType.TRUE_FALSE) {
                if (answerIdToUse == null) {
                    throw new BadRequestException("Answer ID is required for multiple choice or true/false questions");
                }
                Answer answer = answerRepository.findById(answerIdToUse)
                        .orElseThrow(() -> new ResourceNotFoundException("Answer", "id", answerIdToUse));
                builder.answer(answer);
            } else if (question.getQuestionType() == QuestionType.FILL_IN_BLANK) {
                builder.answerText(request.getAnswerText());
            }

            studentAnswerRepository.save(builder.build());
        }

        log.debug("Answer submitted for session: {}, question: {}", sessionId, request.getQuestionId());
    }

    /**
     * Complete exam
     */
    @Transactional
    public ExamResultResponse completeExam(Long sessionId) {
        log.info("Completing exam session: {}", sessionId);

        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));

        // Verify student
        User currentUser = getCurrentUser();
        if (!session.getStudent().getId().equals(currentUser.getId())) {
            throw new ForbiddenException("This exam session is not assigned to you");
        }

        // Check if in progress
        if (session.getStatus() != ExamSessionStatus.IN_PROGRESS) {
            throw new BadRequestException("Exam is not in progress");
        }

        // Complete session
        session.setActualEndTime(LocalDateTime.now());
        session.setStatus(ExamSessionStatus.COMPLETED);
        session.setGradedAt(LocalDateTime.now());
        session.setGradedBy(currentUser);

        // Grade exam
        gradingService.gradeExamSession(session);

        examSessionRepository.save(session);

        log.info("Exam session completed and graded: {}", sessionId);
        return buildExamResultResponse(session);
    }

    /**
     * Get exam result
     */
    public ExamResultResponse getExamResult(Long sessionId) {
        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));

        // Verify permission
        User currentUser = getCurrentUser();
        if (!currentUser.isAdmin() && !currentUser.isTeacher() && !currentUser.isProctor()) {
            if (!session.getStudent().getId().equals(currentUser.getId())) {
                throw new ForbiddenException("You don't have permission to view this result");
            }
        }

        if (session.getStatus() != ExamSessionStatus.COMPLETED) {
            throw new BadRequestException("Exam is not completed yet");
        }

        return buildExamResultResponse(session);
    }

    /**
     * Report violation
     */
    @Transactional
    public void reportViolation(Long sessionId) {
        ExamSession session = examSessionRepository.findById(sessionId)
                .orElseThrow(() -> new ResourceNotFoundException("ExamSession", "id", sessionId));

        session.incrementViolation();
        examSessionRepository.save(session);

        log.warn("Violation reported for session: {}", sessionId);
    }

    // ==================== Helper Methods ====================

    private String generateSessionCode() {
        return "EXAM-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    private TakeExamResponse buildTakeExamResponse(ExamSession session) {
        Exam exam = session.getExam();
        List<ExamQuestion> examQuestions = examQuestionRepository.findByExamId(exam.getId());

        // Shuffle if needed
        if (exam.getIsShuffled()) {
            Collections.shuffle(examQuestions);
        }

        List<TakeExamResponse.ExamQuestionItem> questionItems = examQuestions.stream()
                .map(eq -> {
                    Question question = eq.getQuestion();
                    List<Answer> answers = answerRepository.findByQuestionId(question.getId());

                    // Shuffle answers if needed
                    if (exam.getIsShuffleAnswers()) {
                        Collections.shuffle(answers);
                    }

                    // Get student's submitted answer if exists
                    StudentAnswer submittedAnswer = studentAnswerRepository
                            .findByExamSessionAndQuestion(session, question)
                            .orElse(null);

                    List<TakeExamResponse.AnswerOption> answerOptions = answers.stream()
                            .map(a -> TakeExamResponse.AnswerOption.builder()
                                    .id(a.getId())
                                    .content(a.getContent())
                                    .displayOrder(a.getDisplayOrder())
                                    .build())
                            .collect(Collectors.toList());

                    return TakeExamResponse.ExamQuestionItem.builder()
                            .questionId(question.getId())
                            .content(question.getContent())
                            .questionType(question.getQuestionType())
                            .points(eq.getPoints())
                            .answers(answerOptions)
                            .submittedAnswerId(submittedAnswer != null && submittedAnswer.getAnswer() != null ? 
                                    submittedAnswer.getAnswer().getId() : null)
                            .submittedAnswerText(submittedAnswer != null ? submittedAnswer.getAnswerText() : null)
                            .build();
                })
                .collect(Collectors.toList());

        // Calculate remaining time in seconds
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime actualStart = session.getActualStartTime() != null ? 
                session.getActualStartTime() : session.getStartTime();
        long remainingSeconds = 0;
        if (now.isBefore(session.getEndTime())) {
            remainingSeconds = java.time.Duration.between(now, session.getEndTime()).getSeconds();
        }

        return TakeExamResponse.builder()
                .sessionId(session.getId())
                .sessionCode(session.getSessionCode())
                .examTitle(exam.getTitle())
                .durationMinutes(exam.getDurationMinutes())
                .startTime(actualStart)
                .endTime(session.getEndTime())
                .remainingTime((int) remainingSeconds)
                .questions(questionItems)
                .build();
    }

    private ExamResultResponse buildExamResultResponse(ExamSession session) {
        Exam exam = session.getExam();
        List<StudentAnswer> studentAnswers = studentAnswerRepository.findByExamSession(session);

        long correctCount = studentAnswers.stream().filter(sa -> sa.getIsCorrect() != null && sa.getIsCorrect()).count();

        List<ExamResultResponse.QuestionResult> questionResults = null;
        
        // Only include question results if review is allowed
        if (exam.getAllowReview()) {
            questionResults = studentAnswers.stream()
                    .map(sa -> {
                        String correctAnswer = getCorrectAnswerText(sa.getQuestion());
                        String studentAnswer = sa.getAnswer() != null ? 
                                sa.getAnswer().getContent() : sa.getAnswerText();

                        return ExamResultResponse.QuestionResult.builder()
                                .questionId(sa.getQuestion().getId())
                                .content(sa.getQuestion().getContent())
                                .studentAnswer(studentAnswer)
                                .correctAnswer(correctAnswer)
                                .isCorrect(sa.getIsCorrect())
                                .pointsEarned(sa.getPointsEarned())
                                .maxPoints(sa.getQuestion().getPoints())
                                .explanation(sa.getQuestion().getExplanation())
                                .build();
                    })
                    .collect(Collectors.toList());
        }

        return ExamResultResponse.builder()
                .sessionId(session.getId())
                .sessionCode(session.getSessionCode())
                .examTitle(exam.getTitle())
                .studentName(session.getStudent().getFullName())
                .completedAt(session.getActualEndTime())
                .totalScore(session.getTotalScore())
                .maxScore(exam.getTotalPoints())
                .percentageScore(session.getPercentageScore())
                .isPassed(session.getIsPassed())
                .passingScore(exam.getPassingScore())
                .correctAnswers((int) correctCount)
                .totalQuestions(exam.getTotalQuestions())
                .violationCount(session.getViolationCount())
                .questionResults(questionResults)
                .build();
    }

    private String getCorrectAnswerText(Question question) {
        List<Answer> correctAnswers = answerRepository.findCorrectAnswersByQuestion(question);
        if (correctAnswers.isEmpty()) {
            return "N/A";
        }
        return correctAnswers.stream()
                .map(Answer::getContent)
                .collect(Collectors.joining(", "));
    }

    private ExamSessionResponse toExamSessionResponse(ExamSession session) {
        long answeredCount = studentAnswerRepository.countByExamSession(session);

        return ExamSessionResponse.builder()
                .id(session.getId())
                .examId(session.getExam().getId())
                .examTitle(session.getExam().getTitle())
                .studentId(session.getStudent().getId())
                .studentName(session.getStudent().getFullName())
                .sessionCode(session.getSessionCode())
                .startTime(session.getStartTime())
                .endTime(session.getEndTime())
                .actualStartTime(session.getActualStartTime())
                .actualEndTime(session.getActualEndTime())
                .status(session.getStatus())
                .totalScore(session.getTotalScore())
                .percentageScore(session.getPercentageScore())
                .isPassed(session.getIsPassed())
                .violationCount(session.getViolationCount())
                .answeredQuestions((int) answeredCount)
                .totalQuestions(session.getExam().getTotalQuestions())
                .createdAt(session.getCreatedAt())
                .build();
    }

    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Current user not found"));
    }
}

