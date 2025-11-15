import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<StudentStatsModel> getStudentStatistics(int studentId);
  Future<StudentStatsModel> getMyStatistics();
  Future<ExamStatsModel> getExamStatistics(int examId);
  Future<SubjectStatsModel> getSubjectStatistics(int subjectId);
  Future<DashboardStatsModel> getDashboardStatistics();
}

@LazySingleton(as: StatisticsRemoteDataSource)
class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final ApiClient _apiClient;

  StatisticsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<StudentStatsModel> getStudentStatistics(int studentId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.statistics}/student/$studentId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return StudentStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load student statistics',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading student statistics: $e');
    }
  }

  @override
  Future<StudentStatsModel> getMyStatistics() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.statistics}/my-stats',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return StudentStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load my statistics',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading my statistics: $e');
    }
  }

  @override
  Future<ExamStatsModel> getExamStatistics(int examId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.statistics}/exam/$examId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam statistics',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam statistics: $e');
    }
  }

  @override
  Future<SubjectStatsModel> getSubjectStatistics(int subjectId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.statistics}/subject/$subjectId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return SubjectStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load subject statistics',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading subject statistics: $e');
    }
  }

  @override
  Future<DashboardStatsModel> getDashboardStatistics() async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.statistics}/dashboard',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DashboardStatsModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load dashboard statistics',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading dashboard statistics: $e');
    }
  }
}
