import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remoteDataSource;

  UsersRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<UserModel>>> getAllUsers({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final users = await _remoteDataSource.getAllUsers(page: page, size: size);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load users'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(int id) async {
    try {
      final user = await _remoteDataSource.getUserById(id);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load user'));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsersByRole(
      String roleName) async {
    try {
      final users = await _remoteDataSource.getUsersByRole(roleName);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load users by role'));
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(String keyword) async {
    try {
      final users = await _remoteDataSource.searchUsers(keyword);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search users'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> createUser(
      Map<String, dynamic> data) async {
    try {
      final user = await _remoteDataSource.createUser(data);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create user'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUser(
      int id, Map<String, dynamic> data) async {
    try {
      final user = await _remoteDataSource.updateUser(id, data);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update user'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await _remoteDataSource.deleteUser(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete user'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserStatus(int id) async {
    try {
      await _remoteDataSource.toggleUserStatus(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to toggle user status'));
    }
  }
}
