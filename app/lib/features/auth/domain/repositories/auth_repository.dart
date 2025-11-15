import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(String email, String password);
  Future<Either<Failure, AuthResponse>> register(Map<String, dynamic> data);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel>> getProfile();
  Future<bool> isLoggedIn();
  Future<Either<Failure, AuthResponse>> googleSignIn(String accessToken);
  Future<Either<Failure, UserModel>> updateProfile(
    int userId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, void>> changePassword(
    int userId,
    Map<String, dynamic> data,
  );
}

