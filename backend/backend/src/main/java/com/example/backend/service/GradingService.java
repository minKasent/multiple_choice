package com.example.backend.service;

import com.example.backend.entity.Answer;
import com.example.backend.entity.ExamSession;
import com.example.backend.entity.Question;
import com.example.backend.entity.StudentAnswer;
import com.example.backend.enums.QuestionType;
import com.example.backend.repository.AnswerRepository;
import com.example.backend.repository.StudentAnswerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Service for grading exam answers
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class GradingService {

    private final AnswerRepository answerRepository;
    private final StudentAnswerRepository studentAnswerRepository;

    /**
     * Grade an exam session
     */
    public void gradeExamSession(ExamSession examSession) {
        log.info("Grading exam session: {}", examSession.getId());

        List<StudentAnswer> studentAnswers = studentAnswerRepository.findByExamSession(examSession);
        
        BigDecimal totalScore = BigDecimal.ZERO;
        int correctCount = 0;

        for (StudentAnswer studentAnswer : studentAnswers) {
            BigDecimal pointsEarned = gradeAnswer(studentAnswer);
            studentAnswer.setPointsEarned(pointsEarned);
            totalScore = totalScore.add(pointsEarned);
            
            if (studentAnswer.getIsCorrect()) {
                correctCount++;
            }
            
            studentAnswerRepository.save(studentAnswer);
        }

        // Calculate percentage
        BigDecimal maxScore = examSession.getExam().getTotalPoints();
        BigDecimal percentageScore = BigDecimal.ZERO;
        
        if (maxScore.compareTo(BigDecimal.ZERO) > 0) {
            percentageScore = totalScore.multiply(BigDecimal.valueOf(100))
                    .divide(maxScore, 2, RoundingMode.HALF_UP);
        }

        // Determine if passed
        boolean isPassed = percentageScore.compareTo(examSession.getExam().getPassingScore()) >= 0;

        examSession.setTotalScore(totalScore);
        examSession.setPercentageScore(percentageScore);
        examSession.setIsPassed(isPassed);

        log.info("Exam session graded: {} - Score: {}/{} ({}%)", 
                examSession.getId(), totalScore, maxScore, percentageScore);
    }

    /**
     * Grade a single answer
     */
    private BigDecimal gradeAnswer(StudentAnswer studentAnswer) {
        Question question = studentAnswer.getQuestion();
        BigDecimal maxPoints = question.getPoints();

        if (question.getQuestionType() == QuestionType.MULTIPLE_CHOICE) {
            return gradeMultipleChoice(studentAnswer, maxPoints);
        } else if (question.getQuestionType() == QuestionType.FILL_IN_BLANK) {
            return gradeFillInBlank(studentAnswer, maxPoints);
        } else if (question.getQuestionType() == QuestionType.TRUE_FALSE) {
            return gradeMultipleChoice(studentAnswer, maxPoints); // Same as multiple choice
        }

        return BigDecimal.ZERO;
    }

    /**
     * Grade multiple choice question
     */
    private BigDecimal gradeMultipleChoice(StudentAnswer studentAnswer, BigDecimal maxPoints) {
        if (studentAnswer.getAnswer() == null) {
            studentAnswer.setIsCorrect(false);
            return BigDecimal.ZERO;
        }

        boolean isCorrect = studentAnswer.getAnswer().getIsCorrect();
        studentAnswer.setIsCorrect(isCorrect);

        return isCorrect ? maxPoints : BigDecimal.ZERO;
    }

    /**
     * Grade fill-in-blank question
     */
    private BigDecimal gradeFillInBlank(StudentAnswer studentAnswer, BigDecimal maxPoints) {
        if (studentAnswer.getAnswerText() == null || studentAnswer.getAnswerText().trim().isEmpty()) {
            studentAnswer.setIsCorrect(false);
            return BigDecimal.ZERO;
        }

        // Get correct answers
        List<Answer> correctAnswers = answerRepository.findCorrectAnswersByQuestion(studentAnswer.getQuestion());

        String submittedAnswer = studentAnswer.getAnswerText().trim().toLowerCase();

        // Check if submitted answer matches any correct answer
        boolean isCorrect = correctAnswers.stream()
                .anyMatch(answer -> answer.getContent().trim().toLowerCase().equals(submittedAnswer));

        studentAnswer.setIsCorrect(isCorrect);
        return isCorrect ? maxPoints : BigDecimal.ZERO;
    }
}

