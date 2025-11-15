import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/exam_session_model.dart';

abstract class ExamSessionRemoteDataSource {
  Future<List<ExamSessionModel>> getMyExams();
  Future<ExamSessionModel> getExamSession(int sessionId);
  Future<TakeExamModel> startExam(int sessionId);
  Future<void> submitAnswer(int sessionId, int questionId, List<int> answerIds);
  Future<ExamResultModel> completeExam(int sessionId);
  Future<ExamResultModel> getExamResult(int sessionId);
}

@LazySingleton(as: ExamSessionRemoteDataSource)
class ExamSessionRemoteDataSourceImpl implements ExamSessionRemoteDataSource {
  final ApiClient _apiClient;

  ExamSessionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExamSessionModel>> getMyExams() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.myExams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data']['content'] ?? [];
        return data.map((json) => ExamSessionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exams',
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
  Future<ExamSessionModel> getExamSession(int sessionId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.examSessions}/$sessionId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamSessionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam session',
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
  Future<TakeExamModel> startExam(int sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.examSessions}/$sessionId/start',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return TakeExamModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to start exam',
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
  Future<void> submitAnswer(
    int sessionId,
    int questionId,
    List<int> answerIds,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.examSessions}/$sessionId/submit-answer',
        data: {
          'questionId': questionId,
          'answerIds': answerIds,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to submit answer',
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
  Future<ExamResultModel> completeExam(int sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.examSessions}/$sessionId/complete',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamResultModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to complete exam',
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
  Future<ExamResultModel> getExamResult(int sessionId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.examSessions}/$sessionId/result',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamResultModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam result',
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

