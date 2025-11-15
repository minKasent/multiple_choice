package com.example.backend.service;

import com.example.backend.dto.request.AddQuestionsToExamRequest;
import com.example.backend.dto.request.CreateExamRequest;
import com.example.backend.dto.response.ExamDetailResponse;
import com.example.backend.dto.response.ExamResponse;
import com.example.backend.entity.*;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.mapper.ExamMapper;
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

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for exam management
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ExamService {

    private final ExamRepository examRepository;
    private final SubjectRepository subjectRepository;
    private final QuestionRepository questionRepository;
    private final ExamQuestionRepository examQuestionRepository;
    private final UserRepository userRepository;
    private final ExamMapper examMapper;

    /**
     * Get all exams
     */
    public Page<ExamResponse> getAllExams(Pageable pageable) {
        return examRepository.findByIsActive(true, pageable)
                .map(examMapper::toExamResponse);
    }

    /**
     * Get exams by subject
     */
    public Page<ExamResponse> getExamsBySubject(Long subjectId, Pageable pageable) {
        return examRepository.findBySubjectId(subjectId, pageable)
                .map(examMapper::toExamResponse);
    }

    /**
     * Search exams
     */
    public Page<ExamResponse> searchExams(String keyword, Pageable pageable) {
        return examRepository.searchExams(keyword, pageable)
                .map(examMapper::toExamResponse);
    }

    /**
     * Get exam by ID
     */
    @Transactional(readOnly = true)
    public ExamResponse getExamById(Long id) {
        Exam exam = examRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", id));
        return examMapper.toExamResponse(exam);
    }

    /**
     * Get exam detail with questions
     */
    @Transactional(readOnly = true)
    public ExamDetailResponse getExamDetail(Long id) {
        Exam exam = examRepository.findByIdWithSubject(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", id));
        return examMapper.toExamDetailResponse(exam);
    }

    /**
     * Create new exam
     */
    @Transactional
    public ExamResponse createExam(CreateExamRequest request) {
        log.info("Creating new exam: {}", request.getTitle());

        Subject subject = subjectRepository.findById(request.getSubjectId())
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", request.getSubjectId()));

        User currentUser = getCurrentUser();

        Exam exam = Exam.builder()
                .subject(subject)
                .title(request.getTitle())
                .description(request.getDescription())
                .durationMinutes(request.getDurationMinutes())
                .totalQuestions(0)
                .totalPoints(BigDecimal.ZERO)
                .passingScore(request.getPassingScore())
                .examType(request.getExamType())
                .isShuffled(request.getIsShuffled())
                .isShuffleAnswers(request.getIsShuffleAnswers())
                .showResultImmediately(request.getShowResultImmediately())
                .allowReview(request.getAllowReview())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Exam savedExam = examRepository.save(exam);
        log.info("Exam created successfully: {}", savedExam.getId());

        return examMapper.toExamResponse(savedExam);
    }

    /**
     * Update exam
     */
    @Transactional
    public ExamResponse updateExam(Long id, CreateExamRequest request) {
        log.info("Updating exam: {}", id);

        Exam exam = examRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", id));

        if (request.getTitle() != null) {
            exam.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            exam.setDescription(request.getDescription());
        }
        if (request.getDurationMinutes() != null) {
            exam.setDurationMinutes(request.getDurationMinutes());
        }
        if (request.getPassingScore() != null) {
            exam.setPassingScore(request.getPassingScore());
        }
        if (request.getExamType() != null) {
            exam.setExamType(request.getExamType());
        }
        if (request.getIsShuffled() != null) {
            exam.setIsShuffled(request.getIsShuffled());
        }
        if (request.getIsShuffleAnswers() != null) {
            exam.setIsShuffleAnswers(request.getIsShuffleAnswers());
        }
        if (request.getShowResultImmediately() != null) {
            exam.setShowResultImmediately(request.getShowResultImmediately());
        }
        if (request.getAllowReview() != null) {
            exam.setAllowReview(request.getAllowReview());
        }

        exam.setUpdatedBy(getCurrentUser());
        Exam updatedExam = examRepository.save(exam);

        log.info("Exam updated successfully: {}", id);
        return examMapper.toExamResponse(updatedExam);
    }

    /**
     * Delete exam (soft delete)
     */
    @Transactional
    public void deleteExam(Long id) {
        log.info("Deleting exam: {}", id);

        Exam exam = examRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", id));

        exam.setIsActive(false);
        exam.setUpdatedBy(getCurrentUser());
        examRepository.save(exam);

        log.info("Exam deleted successfully: {}", id);
    }

    /**
     * Add questions to exam
     */
    @Transactional
    public ExamDetailResponse addQuestionsToExam(Long examId, AddQuestionsToExamRequest request) {
        log.info("Adding {} questions to exam: {}", request.getQuestions().size(), examId);

        Exam exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", examId));

        BigDecimal totalPoints = exam.getTotalPoints();
        int totalQuestions = exam.getTotalQuestions();
        int addedCount = 0;
        int skippedCount = 0;

        for (var questionItem : request.getQuestions()) {
            Question question = questionRepository.findById(questionItem.getQuestionId())
                    .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionItem.getQuestionId()));

            // Check if question already in exam
            if (examQuestionRepository.existsByExamAndQuestion(exam, question)) {
                log.warn("Question {} already exists in exam {}, skipping", question.getId(), examId);
                skippedCount++;
                continue;
            }

            ExamQuestion examQuestion = ExamQuestion.builder()
                    .exam(exam)
                    .question(question)
                    .displayOrder(questionItem.getDisplayOrder())
                    .points(questionItem.getPoints())
                    .build();

            examQuestionRepository.save(examQuestion);

            totalPoints = totalPoints.add(questionItem.getPoints());
            totalQuestions++;
            addedCount++;
        }

        if (addedCount == 0 && skippedCount > 0) {
            throw new BadRequestException("All questions already exist in exam");
        }

        exam.setTotalPoints(totalPoints);
        exam.setTotalQuestions(totalQuestions);
        exam.setUpdatedBy(getCurrentUser());
        examRepository.save(exam);

        if (skippedCount > 0) {
            log.info("Added {} questions to exam: {}, skipped {} existing questions", addedCount, examId, skippedCount);
        } else {
            log.info("Added {} questions successfully to exam: {}", addedCount, examId);
        }
        return examMapper.toExamDetailResponse(exam);
    }

    /**
     * Remove question from exam
     */
    @Transactional
    public void removeQuestionFromExam(Long examId, Long questionId) {
        log.info("Removing question {} from exam: {}", questionId, examId);

        Exam exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", examId));

        Question question = questionRepository.findById(questionId)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", questionId));

        ExamQuestion examQuestion = examQuestionRepository.findByExamAndQuestion(exam, question)
                .orElseThrow(() -> new BadRequestException("Question not found in exam"));

        exam.setTotalPoints(exam.getTotalPoints().subtract(examQuestion.getPoints()));
        exam.setTotalQuestions(exam.getTotalQuestions() - 1);
        exam.setUpdatedBy(getCurrentUser());
        examRepository.save(exam);

        examQuestionRepository.delete(examQuestion);

        log.info("Question removed successfully from exam: {}", examId);
    }

    /**
     * Shuffle exam questions
     */
    @Transactional
    public ExamDetailResponse shuffleExam(Long examId) {
        log.info("Shuffling exam: {}", examId);

        Exam exam = examRepository.findById(examId)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", examId));

        List<ExamQuestion> examQuestions = examQuestionRepository.findByExamId(examId);

        if (examQuestions.isEmpty()) {
            throw new BadRequestException("Cannot shuffle exam with no questions");
        }

        // Shuffle the list
        Collections.shuffle(examQuestions);

        // Update display order
        for (int i = 0; i < examQuestions.size(); i++) {
            examQuestions.get(i).setDisplayOrder(i + 1);
            examQuestionRepository.save(examQuestions.get(i));
        }

        exam.setUpdatedBy(getCurrentUser());
        examRepository.save(exam);

        log.info("Exam shuffled successfully: {}", examId);
        return examMapper.toExamDetailResponse(exam);
    }

    /**
     * Clone exam
     */
    @Transactional
    public ExamResponse cloneExam(Long examId) {
        log.info("Cloning exam: {}", examId);

        Exam originalExam = examRepository.findById(examId)
                .orElseThrow(() -> new ResourceNotFoundException("Exam", "id", examId));

        User currentUser = getCurrentUser();

        // Create new exam
        Exam clonedExam = Exam.builder()
                .subject(originalExam.getSubject())
                .title(originalExam.getTitle() + " (Copy)")
                .description(originalExam.getDescription())
                .durationMinutes(originalExam.getDurationMinutes())
                .totalQuestions(originalExam.getTotalQuestions())
                .totalPoints(originalExam.getTotalPoints())
                .passingScore(originalExam.getPassingScore())
                .examType(originalExam.getExamType())
                .isShuffled(originalExam.getIsShuffled())
                .isShuffleAnswers(originalExam.getIsShuffleAnswers())
                .showResultImmediately(originalExam.getShowResultImmediately())
                .allowReview(originalExam.getAllowReview())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Exam savedExam = examRepository.save(clonedExam);

        // Clone questions
        List<ExamQuestion> originalQuestions = examQuestionRepository.findByExamId(examId);
        for (ExamQuestion original : originalQuestions) {
            ExamQuestion cloned = ExamQuestion.builder()
                    .exam(savedExam)
                    .question(original.getQuestion())
                    .displayOrder(original.getDisplayOrder())
                    .points(original.getPoints())
                    .build();

            examQuestionRepository.save(cloned);
        }

        log.info("Exam cloned successfully: {} -> {}", examId, savedExam.getId());
        return examMapper.toExamResponse(savedExam);
    }

    /**
     * Get current authenticated user
     */
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        UserDetailsImpl userDetails = (UserDetailsImpl) authentication.getPrincipal();
        return userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Current user not found"));
    }
}

