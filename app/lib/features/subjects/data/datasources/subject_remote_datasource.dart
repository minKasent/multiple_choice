import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/subject_model.dart';

abstract class SubjectRemoteDataSource {
  Future<List<SubjectModel>> getSubjects({int page = 0, int size = 20});
  Future<SubjectModel> getSubjectById(int id);
  Future<SubjectModel> createSubject(Map<String, dynamic> data);
  Future<SubjectModel> updateSubject(int id, Map<String, dynamic> data);
  Future<void> deleteSubject(int id);
}

@LazySingleton(as: SubjectRemoteDataSource)
class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final ApiClient _apiClient;

  SubjectRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SubjectModel>> getSubjects({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.subjects,
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data['items'] != null) {
          return (data['items'] as List)
              .map((e) => SubjectModel.fromJson(e))
              .toList();
        }
        return [];
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get subjects',
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
  Future<SubjectModel> getSubjectById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.subjects}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubjectModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get subject',
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
  Future<SubjectModel> createSubject(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.subjects,
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubjectModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create subject',
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
  Future<SubjectModel> updateSubject(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.subjects}/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubjectModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update subject',
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
  Future<void> deleteSubject(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.subjects}/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete subject',
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

