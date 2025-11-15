import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getAllUsers({int page = 0, int size = 20});
  Future<UserModel> getUserById(int id);
  Future<List<UserModel>> getUsersByRole(String roleName);
  Future<List<UserModel>> searchUsers(String keyword);
  Future<UserModel> createUser(Map<String, dynamic> data);
  Future<UserModel> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<void> toggleUserStatus(int id);
}

@LazySingleton(as: UsersRemoteDataSource)
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient _apiClient;

  UsersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<UserModel>> getAllUsers({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.users,
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'] ?? [];
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load users',
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
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.users}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load user',
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
  Future<List<UserModel>> getUsersByRole(String roleName) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.users}/role/$roleName',
        queryParameters: {
          'size': 1000, // Load tất cả học sinh
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'] ?? [];
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load users by role',
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
  Future<List<UserModel>> searchUsers(String keyword) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.users}/search',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'] ?? [];
        return data.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to search users',
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
  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(ApiConstants.users, data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create user',
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
  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update user',
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
  Future<void> deleteUser(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.users}/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete user',
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
  Future<void> toggleUserStatus(int id) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.users}/$id/toggle-status',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to toggle user status',
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
