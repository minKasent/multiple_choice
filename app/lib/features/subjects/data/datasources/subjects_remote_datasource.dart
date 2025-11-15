import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/subject_model.dart';

abstract class SubjectsRemoteDataSource {
  Future<List<SubjectModel>> getAllSubjects();
  Future<SubjectModel> getSubjectById(int id);
  Future<List<SubjectModel>> searchSubjects(String keyword);
  Future<SubjectModel> createSubject(Map<String, dynamic> data);
  Future<SubjectModel> updateSubject(int id, Map<String, dynamic> data);
  Future<void> deleteSubject(int id);
}

@LazySingleton(as: SubjectsRemoteDataSource)
class SubjectsRemoteDataSourceImpl implements SubjectsRemoteDataSource {
  final ApiClient _apiClient;

  SubjectsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<SubjectModel>> getAllSubjects() async {
    try {
      final response = await _apiClient.get('${ApiConstants.subjects}/list');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => SubjectModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load subjects',
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
          message: response.data['message'] ?? 'Failed to load subject',
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
  Future<List<SubjectModel>> searchSubjects(String keyword) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.subjects}/search',
        queryParameters: {'keyword': keyword},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'] ?? [];
        return data.map((json) => SubjectModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to search subjects',
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

