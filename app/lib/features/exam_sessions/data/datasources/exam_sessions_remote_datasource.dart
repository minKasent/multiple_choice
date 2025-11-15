import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_session_model.dart';

abstract class ExamSessionsRemoteDataSource {
  Future<List<ExamSessionModel>> scheduleExam(ScheduleExamRequest request);
  Future<List<ExamSessionModel>> getMyExams({int page = 0, int size = 20});
  Future<ExamSessionModel> getExamSession(int id);
}

@LazySingleton(as: ExamSessionsRemoteDataSource)
class ExamSessionsRemoteDataSourceImpl implements ExamSessionsRemoteDataSource {
  final ApiClient _apiClient;

  ExamSessionsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExamSessionModel>> scheduleExam(
    ScheduleExamRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.examSessions}/schedule',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((json) => ExamSessionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to schedule exam',
        );
      }
    } on DioException catch (e) {
      // Parse validation errors from backend
      if (e.response?.statusCode == 400 && e.response?.data != null) {
        final errorData = e.response!.data;
        final fieldErrors = errorData['fieldErrors'] as List?;
        
        if (fieldErrors != null && fieldErrors.isNotEmpty) {
          // Get first field error message
          final firstError = fieldErrors.first;
          final errorMessage = firstError['message'] ?? errorData['message'] ?? 'Validation failed';
          throw ServerException(
            message: errorMessage,
            statusCode: 400,
          );
        }
      }
      
      throw ServerException(
        message: e.response?.data['message'] ?? 'Error scheduling exam: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Error scheduling exam: $e');
    }
  }

  @override
  Future<List<ExamSessionModel>> getMyExams({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.myExams,
        queryParameters: {'page': page, 'size': size, 'sort': 'startTime,desc'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final content = data['content'] as List;
        return content.map((json) => ExamSessionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load my exams',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading my exams: $e');
    }
  }

  @override
  Future<ExamSessionModel> getExamSession(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.examSessions}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam session',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam session: $e');
    }
  }
}
