package com.example.backend.service;

import com.example.backend.dto.request.CreateChapterRequest;
import com.example.backend.dto.request.CreatePassageRequest;
import com.example.backend.dto.request.CreateQuestionRequest;
import com.example.backend.dto.response.ChapterResponse;
import com.example.backend.dto.response.PassageResponse;
import com.example.backend.dto.response.QuestionResponse;
import com.example.backend.entity.*;
import com.example.backend.exception.BadRequestException;
import com.example.backend.exception.ResourceNotFoundException;
import com.example.backend.mapper.QuestionMapper;
import com.example.backend.repository.*;
import com.example.backend.security.UserDetailsImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service for question bank management (Chapter, Passage, Question, Answer)
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class QuestionBankService {

    private final SubjectRepository subjectRepository;
    private final ChapterRepository chapterRepository;
    private final PassageRepository passageRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final UserRepository userRepository;
    private final QuestionMapper questionMapper;

    // ==================== CHAPTER OPERATIONS ====================

    /**
     * Get all chapters by subject
     */
    @Transactional(readOnly = true)
    public List<ChapterResponse> getChaptersBySubject(Long subjectId) {
        Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", subjectId));

        return chapterRepository.findBySubjectId(subjectId).stream()
                .map(questionMapper::toChapterResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get chapter by ID
     */
    @Transactional(readOnly = true)
    public ChapterResponse getChapterById(Long id) {
        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", id));
        return questionMapper.toChapterResponse(chapter);
    }

    /**
     * Create new chapter
     */
    @Transactional
    public ChapterResponse createChapter(Long subjectId, CreateChapterRequest request) {
        log.info("Creating new chapter for subject: {}", subjectId);

        Subject subject = subjectRepository.findById(subjectId)
                .orElseThrow(() -> new ResourceNotFoundException("Subject", "id", subjectId));

        // Check if chapter number already exists
        if (chapterRepository.existsBySubjectAndChapterNumber(subject, request.getChapterNumber())) {
            throw new BadRequestException("Chapter number already exists: " + request.getChapterNumber());
        }

        User currentUser = getCurrentUser();

        Chapter chapter = Chapter.builder()
                .subject(subject)
                .chapterNumber(request.getChapterNumber())
                .title(request.getTitle())
                .description(request.getDescription())
                .displayOrder(request.getDisplayOrder())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Chapter savedChapter = chapterRepository.save(chapter);
        log.info("Chapter created successfully: {}", savedChapter.getId());

        return questionMapper.toChapterResponse(savedChapter);
    }

    /**
     * Update chapter
     */
    @Transactional
    public ChapterResponse updateChapter(Long id, CreateChapterRequest request) {
        log.info("Updating chapter: {}", id);

        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", id));

        if (request.getTitle() != null) {
            chapter.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            chapter.setDescription(request.getDescription());
        }
        if (request.getDisplayOrder() != null) {
            chapter.setDisplayOrder(request.getDisplayOrder());
        }

        chapter.setUpdatedBy(getCurrentUser());
        Chapter updatedChapter = chapterRepository.save(chapter);

        log.info("Chapter updated successfully: {}", id);
        return questionMapper.toChapterResponse(updatedChapter);
    }

    /**
     * Delete chapter
     */
    @Transactional
    public void deleteChapter(Long id) {
        log.info("Deleting chapter: {}", id);

        Chapter chapter = chapterRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", id));

        chapter.setIsActive(false);
        chapter.setUpdatedBy(getCurrentUser());
        chapterRepository.save(chapter);

        log.info("Chapter deleted successfully: {}", id);
    }

    // ==================== PASSAGE OPERATIONS ====================

    /**
     * Get all passages by chapter
     */
    @Transactional(readOnly = true)
    public List<PassageResponse> getPassagesByChapter(Long chapterId) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", chapterId));

        return passageRepository.findByChapterId(chapterId).stream()
                .map(questionMapper::toPassageResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get passage by ID
     */
    @Transactional(readOnly = true)
    public PassageResponse getPassageById(Long id) {
        Passage passage = passageRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Passage", "id", id));
        return questionMapper.toPassageResponse(passage);
    }

    /**
     * Create new passage
     */
    @Transactional
    public PassageResponse createPassage(Long chapterId, CreatePassageRequest request) {
        log.info("Creating new passage for chapter: {}", chapterId);

        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", chapterId));

        User currentUser = getCurrentUser();

        Passage passage = Passage.builder()
                .chapter(chapter)
                .title(request.getTitle())
                .content(request.getContent())
                .displayOrder(request.getDisplayOrder())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Passage savedPassage = passageRepository.save(passage);
        log.info("Passage created successfully: {}", savedPassage.getId());

        return questionMapper.toPassageResponse(savedPassage);
    }

    /**
     * Update passage
     */
    @Transactional
    public PassageResponse updatePassage(Long id, CreatePassageRequest request) {
        log.info("Updating passage: {}", id);

        Passage passage = passageRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Passage", "id", id));

        if (request.getTitle() != null) {
            passage.setTitle(request.getTitle());
        }
        if (request.getContent() != null) {
            passage.setContent(request.getContent());
        }
        if (request.getDisplayOrder() != null) {
            passage.setDisplayOrder(request.getDisplayOrder());
        }

        passage.setUpdatedBy(getCurrentUser());
        Passage updatedPassage = passageRepository.save(passage);

        log.info("Passage updated successfully: {}", id);
        return questionMapper.toPassageResponse(updatedPassage);
    }

    /**
     * Delete passage
     */
    @Transactional
    public void deletePassage(Long id) {
        log.info("Deleting passage: {}", id);

        Passage passage = passageRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Passage", "id", id));

        passage.setIsActive(false);
        passage.setUpdatedBy(getCurrentUser());
        passageRepository.save(passage);

        log.info("Passage deleted successfully: {}", id);
    }

    // ==================== QUESTION OPERATIONS ====================

    /**
     * Get all questions by passage
     */
    @Transactional(readOnly = true)
    public List<QuestionResponse> getQuestionsByPassage(Long passageId) {
        Passage passage = passageRepository.findById(passageId)
                .orElseThrow(() -> new ResourceNotFoundException("Passage", "id", passageId));

        return questionRepository.findByPassageId(passageId).stream()
                .map(questionMapper::toQuestionResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get all questions by chapter
     */
    @Transactional(readOnly = true)
    public List<QuestionResponse> getQuestionsByChapter(Long chapterId) {
        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", chapterId));

        return questionRepository.findByChapterId(chapterId).stream()
                .map(questionMapper::toQuestionResponse)
                .collect(Collectors.toList());
    }

    /**
     * Get question by ID
     */
    @Transactional(readOnly = true)
    public QuestionResponse getQuestionById(Long id) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));
        return questionMapper.toQuestionResponse(question);
    }

    /**
     * Create new question with answers for a chapter (creates default passage if needed)
     */
    @Transactional
    public QuestionResponse createQuestionForChapter(Long chapterId, CreateQuestionRequest request) {
        log.info("Creating new question for chapter: {}", chapterId);

        Chapter chapter = chapterRepository.findById(chapterId)
                .orElseThrow(() -> new ResourceNotFoundException("Chapter", "id", chapterId));

        // Find or create default passage for this chapter
        List<Passage> passages = passageRepository.findByChapterId(chapterId);
        Passage passage;
        
        if (passages.isEmpty()) {
            // Create default passage
            User currentUser = getCurrentUser();
            passage = Passage.builder()
                    .chapter(chapter)
                    .title("Mặc định")
                    .content("Đoạn văn mặc định cho các câu hỏi chung")
                    .displayOrder(1)
                    .isActive(true)
                    .createdBy(currentUser)
                    .build();
            passage = passageRepository.save(passage);
            log.info("Created default passage for chapter: {}", chapterId);
        } else {
            // Use first passage as default
            passage = passages.get(0);
        }

        return createQuestionForPassage(passage.getId(), request);
    }

    /**
     * Create new question with answers for a passage
     */
    @Transactional
    public QuestionResponse createQuestionForPassage(Long passageId, CreateQuestionRequest request) {
        log.info("Creating new question for passage: {}", passageId);

        Passage passage = passageRepository.findById(passageId)
                .orElseThrow(() -> new ResourceNotFoundException("Passage", "id", passageId));

        // Validate at least one correct answer
        if (request.getAnswers() == null || request.getAnswers().isEmpty()) {
            throw new BadRequestException("Question must have at least one answer");
        }

        long correctAnswersCount = request.getAnswers().stream()
                .filter(CreateQuestionRequest.CreateAnswerRequest::getIsCorrect)
                .count();

        if (correctAnswersCount == 0) {
            throw new BadRequestException("Question must have at least one correct answer");
        }

        User currentUser = getCurrentUser();

        Question question = Question.builder()
                .passage(passage)
                .questionType(request.getQuestionType())
                .content(request.getContent())
                .explanation(request.getExplanation())
                .difficultyLevel(request.getDifficultyLevel())
                .points(BigDecimal.valueOf(request.getPoints()))
                .displayOrder(request.getDisplayOrder())
                .isActive(true)
                .createdBy(currentUser)
                .build();

        Question savedQuestion = questionRepository.save(question);

        // Create answers
        for (CreateQuestionRequest.CreateAnswerRequest answerRequest : request.getAnswers()) {
            Answer answer = Answer.builder()
                    .question(savedQuestion)
                    .content(answerRequest.getContent())
                    .isCorrect(answerRequest.getIsCorrect())
                    .displayOrder(answerRequest.getDisplayOrder())
                    .isActive(true)
                    .createdBy(currentUser)
                    .build();

            answerRepository.save(answer);
        }

        log.info("Question created successfully: {}", savedQuestion.getId());

        // Reload question with answers
        return getQuestionById(savedQuestion.getId());
    }

    /**
     * Update question
     */
    @Transactional
    public QuestionResponse updateQuestion(Long id, CreateQuestionRequest request) {
        log.info("Updating question: {}", id);

        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));

        if (request.getContent() != null) {
            question.setContent(request.getContent());
        }
        if (request.getExplanation() != null) {
            question.setExplanation(request.getExplanation());
        }
        if (request.getDifficultyLevel() != null) {
            question.setDifficultyLevel(request.getDifficultyLevel());
        }
        if (request.getPoints() != null) {
            question.setPoints(BigDecimal.valueOf(request.getPoints()));
        }
        if (request.getDisplayOrder() != null) {
            question.setDisplayOrder(request.getDisplayOrder());
        }

        question.setUpdatedBy(getCurrentUser());
        questionRepository.save(question);

        // Update answers if provided
        if (request.getAnswers() != null && !request.getAnswers().isEmpty()) {
            // Validate at least one correct answer
            long correctAnswersCount = request.getAnswers().stream()
                    .filter(CreateQuestionRequest.CreateAnswerRequest::getIsCorrect)
                    .count();

            if (correctAnswersCount == 0) {
                throw new BadRequestException("Question must have at least one correct answer");
            }

            // Delete old answers
            List<Answer> oldAnswers = answerRepository.findByQuestion(question);
            answerRepository.deleteAll(oldAnswers);

            // Create new answers
            User currentUser = getCurrentUser();
            for (CreateQuestionRequest.CreateAnswerRequest answerRequest : request.getAnswers()) {
                Answer answer = Answer.builder()
                        .question(question)
                        .content(answerRequest.getContent())
                        .isCorrect(answerRequest.getIsCorrect())
                        .displayOrder(answerRequest.getDisplayOrder())
                        .isActive(true)
                        .createdBy(currentUser)
                        .build();

                answerRepository.save(answer);
            }
        }

        log.info("Question updated successfully: {}", id);
        return getQuestionById(id);
    }

    /**
     * Delete question
     */
    @Transactional
    public void deleteQuestion(Long id) {
        log.info("Deleting question: {}", id);

        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Question", "id", id));

        question.setIsActive(false);
        question.setUpdatedBy(getCurrentUser());
        questionRepository.save(question);

        log.info("Question deleted successfully: {}", id);
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

