import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/subjects_repository.dart';
import '../datasources/subjects_remote_datasource.dart';
import '../models/subject_model.dart';

@LazySingleton(as: SubjectsRepository)
class SubjectsRepositoryImpl implements SubjectsRepository {
  final SubjectsRemoteDataSource _remoteDataSource;

  SubjectsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<SubjectModel>>> getAllSubjects() async {
    try {
      final subjects = await _remoteDataSource.getAllSubjects();
      return Right(subjects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load subjects'));
    }
  }

  @override
  Future<Either<Failure, SubjectModel>> getSubjectById(int id) async {
    try {
      final subject = await _remoteDataSource.getSubjectById(id);
      return Right(subject);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load subject'));
    }
  }

  @override
  Future<Either<Failure, List<SubjectModel>>> searchSubjects(String keyword) async {
    try {
      final subjects = await _remoteDataSource.searchSubjects(keyword);
      return Right(subjects);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search subjects'));
    }
  }

  @override
  Future<Either<Failure, SubjectModel>> createSubject(Map<String, dynamic> data) async {
    try {
      final subject = await _remoteDataSource.createSubject(data);
      return Right(subject);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create subject'));
    }
  }

  @override
  Future<Either<Failure, SubjectModel>> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      final subject = await _remoteDataSource.updateSubject(id, data);
      return Right(subject);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update subject'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubject(int id) async {
    try {
      await _remoteDataSource.deleteSubject(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete subject'));
    }
  }
}

