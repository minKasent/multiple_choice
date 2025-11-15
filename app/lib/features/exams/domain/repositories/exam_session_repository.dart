import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/exam_session_model.dart';

abstract class ExamSessionRepository {
  Future<Either<Failure, List<ExamSessionModel>>> getMyExams();
  Future<Either<Failure, ExamSessionModel>> getExamSession(int sessionId);
  Future<Either<Failure, TakeExamModel>> startExam(int sessionId);
  Future<Either<Failure, void>> submitAnswer(
    int sessionId,
    int questionId,
    List<int> answerIds,
  );
  Future<Either<Failure, ExamResultModel>> completeExam(int sessionId);
  Future<Either<Failure, ExamResultModel>> getExamResult(int sessionId);
}

