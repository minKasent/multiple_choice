import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_model.dart';

abstract class ExamsRemoteDataSource {
  Future<List<ExamModel>> getAllExams({int page = 0, int size = 20});
  Future<List<ExamModel>> getExamsBySubject(
    int subjectId, {
    int page = 0,
    int size = 20,
  });
  Future<List<ExamModel>> searchExams(
    String keyword, {
    int page = 0,
    int size = 20,
  });
  Future<ExamModel> getExamById(int id);
  Future<ExamDetailModel> getExamDetail(int id);
  Future<ExamModel> createExam(CreateExamRequest request);
  Future<ExamModel> updateExam(int id, CreateExamRequest request);
  Future<void> deleteExam(int id);
  Future<ExamDetailModel> addQuestionsToExam(
    int examId,
    AddQuestionsRequest request,
  );
  Future<void> removeQuestionFromExam(int examId, int questionId);
  Future<ExamDetailModel> shuffleExam(int examId);
  Future<ExamModel> cloneExam(int examId);
}

@LazySingleton(as: ExamsRemoteDataSource)
class ExamsRemoteDataSourceImpl implements ExamsRemoteDataSource {
  final ApiClient _apiClient;

  ExamsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExamModel>> getAllExams({int page = 0, int size = 20}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.exams,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'id,desc',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final content = data['content'] as List;
        return content.map((json) => ExamModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exams',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exams: $e');
    }
  }

  @override
  Future<List<ExamModel>> getExamsBySubject(
    int subjectId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.exams}/subject/$subjectId',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final content = data['content'] as List;
        return content.map((json) => ExamModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exams by subject',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exams by subject: $e');
    }
  }

  @override
  Future<List<ExamModel>> searchExams(
    String keyword, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.exams}/search',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final content = data['content'] as List;
        return content.map((json) => ExamModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to search exams',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error searching exams: $e');
    }
  }

  @override
  Future<ExamModel> getExamById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.exams}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam: $e');
    }
  }

  @override
  Future<ExamDetailModel> getExamDetail(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.exams}/$id/detail');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamDetailModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam detail',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam detail: $e');
    }
  }

  @override
  Future<ExamModel> createExam(CreateExamRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.exams,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error creating exam: $e');
    }
  }

  @override
  Future<ExamModel> updateExam(int id, CreateExamRequest request) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.exams}/$id',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error updating exam: $e');
    }
  }

  @override
  Future<void> deleteExam(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.exams}/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error deleting exam: $e');
    }
  }

  @override
  Future<ExamDetailModel> addQuestionsToExam(
    int examId,
    AddQuestionsRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.exams}/$examId/questions',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamDetailModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to add questions to exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error adding questions to exam: $e');
    }
  }

  @override
  Future<void> removeQuestionFromExam(int examId, int questionId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.exams}/$examId/questions/$questionId',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to remove question from exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error removing question from exam: $e');
    }
  }

  @override
  Future<ExamDetailModel> shuffleExam(int examId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.exams}/$examId/shuffle',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamDetailModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to shuffle exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error shuffling exam: $e');
    }
  }

  @override
  Future<ExamModel> cloneExam(int examId) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.exams}/$examId/clone',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to clone exam',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error cloning exam: $e');
    }
  }
}
