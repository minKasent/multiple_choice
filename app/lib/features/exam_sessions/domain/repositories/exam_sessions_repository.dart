import 'package:app/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/exam_session_model.dart';

abstract class ExamSessionsRepository {
  Future<Either<Failure, List<ExamSessionModel>>> scheduleExam(
    ScheduleExamRequest request,
  );

  Future<Either<Failure, List<ExamSessionModel>>> getMyExams({
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, ExamSessionModel>> getExamSession(int id);
}
