import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/subject_model.dart';

abstract class SubjectsRepository {
  Future<Either<Failure, List<SubjectModel>>> getAllSubjects();
  Future<Either<Failure, SubjectModel>> getSubjectById(int id);
  Future<Either<Failure, List<SubjectModel>>> searchSubjects(String keyword);
  Future<Either<Failure, SubjectModel>> createSubject(Map<String, dynamic> data);
  Future<Either<Failure, SubjectModel>> updateSubject(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteSubject(int id);
}

