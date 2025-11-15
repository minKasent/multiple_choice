import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/exam_model.dart';

abstract class ExamsRepository {
  Future<Either<Failure, List<ExamModel>>> getAllExams({
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, List<ExamModel>>> getExamsBySubject(
    int subjectId, {
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, List<ExamModel>>> searchExams(
    String keyword, {
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, ExamModel>> getExamById(int id);

  Future<Either<Failure, ExamDetailModel>> getExamDetail(int id);

  Future<Either<Failure, ExamModel>> createExam(CreateExamRequest request);

  Future<Either<Failure, ExamModel>> updateExam(
    int id,
    CreateExamRequest request,
  );

  Future<Either<Failure, void>> deleteExam(int id);

  Future<Either<Failure, ExamDetailModel>> addQuestionsToExam(
    int examId,
    AddQuestionsRequest request,
  );

  Future<Either<Failure, void>> removeQuestionFromExam(
    int examId,
    int questionId,
  );

  Future<Either<Failure, ExamDetailModel>> shuffleExam(int examId);

  Future<Either<Failure, ExamModel>> cloneExam(int examId);
}
