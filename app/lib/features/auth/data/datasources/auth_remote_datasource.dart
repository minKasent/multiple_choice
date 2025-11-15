import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> register(Map<String, dynamic> data);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout();
  Future<UserModel> getProfile();
  Future<AuthResponse> googleSignIn(String accessToken);
  Future<UserModel> updateProfile(int userId, Map<String, dynamic> data);
  Future<void> changePassword(int userId, Map<String, dynamic> data);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Đăng nhập thất bại',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Lỗi kết nối';
      // Map các error message phổ biến sang tiếng Việt
      final message = _mapErrorMessage(errorMessage);
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Map error messages từ tiếng Anh sang tiếng Việt
  String _mapErrorMessage(String message) {
    final errorMap = {
      'Bad credentials': 'Email hoặc mật khẩu không đúng',
      'User not found': 'Không tìm thấy người dùng',
      'Invalid password': 'Mật khẩu không đúng',
      'Account is locked': 'Tài khoản đã bị khóa',
      'Account is disabled': 'Tài khoản đã bị vô hiệu hóa',
      'Email is already in use': 'Email đã được sử dụng',
      'Username is already taken': 'Tên đăng nhập đã được sử dụng',
      'Network error': 'Lỗi kết nối',
      'Unauthorized': 'Không có quyền truy cập',
    };

    return errorMap[message] ?? message;
  }

  @override
  Future<AuthResponse> register(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Đăng ký thất bại',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Lỗi kết nối';
      final message = _mapErrorMessage(errorMessage);
      throw ServerException(
        message: message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw UnauthorizedException(
          message: response.data['message'] ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      throw UnauthorizedException(
        message: e.response?.data['message'] ?? 'Unauthorized',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Logout failed',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get profile',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          message: e.response?.data['message'] ?? 'Unauthorized',
        );
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<AuthResponse> googleSignIn(String accessToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'accessToken': accessToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AuthResponse.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Google sign in failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<UserModel> updateProfile(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/$userId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Update profile failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> changePassword(int userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/$userId/change-password',
        data: data,
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Change password failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

