import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/user_model.dart';

abstract class UsersRepository {
  Future<Either<Failure, List<UserModel>>> getAllUsers({int page = 0, int size = 20});
  Future<Either<Failure, UserModel>> getUserById(int id);
  Future<Either<Failure, List<UserModel>>> getUsersByRole(String roleName);
  Future<Either<Failure, List<UserModel>>> searchUsers(String keyword);
  Future<Either<Failure, UserModel>> createUser(Map<String, dynamic> data);
  Future<Either<Failure, UserModel>> updateUser(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteUser(int id);
  Future<Either<Failure, void>> toggleUserStatus(int id);
}
