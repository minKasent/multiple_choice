import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/chapter_model.dart';
import '../models/passage_model.dart';
import '../models/question_model.dart';

abstract class QuestionBankRemoteDataSource {
  // Chapters
  Future<List<ChapterModel>> getChaptersBySubject(int subjectId);
  Future<ChapterModel> getChapterById(int id);
  Future<ChapterModel> createChapter(int subjectId, Map<String, dynamic> data);
  Future<ChapterModel> updateChapter(int id, Map<String, dynamic> data);
  Future<void> deleteChapter(int id);

  // Passages
  Future<List<PassageModel>> getPassagesByChapter(int chapterId);
  Future<PassageModel> getPassageById(int id);
  Future<PassageModel> createPassage(int chapterId, Map<String, dynamic> data);
  Future<PassageModel> updatePassage(int id, Map<String, dynamic> data);
  Future<void> deletePassage(int id);

  // Questions
  Future<List<QuestionModel>> getQuestionsByPassage(int passageId);
  Future<List<QuestionModel>> getQuestionsByChapter(int chapterId);
  Future<QuestionModel> getQuestionById(int id);
  Future<QuestionModel> createQuestion(Map<String, dynamic> data);
  Future<QuestionModel> updateQuestion(int id, Map<String, dynamic> data);
  Future<void> deleteQuestion(int id);
}

@LazySingleton(as: QuestionBankRemoteDataSource)
class QuestionBankRemoteDataSourceImpl implements QuestionBankRemoteDataSource {
  final ApiClient _apiClient;

  QuestionBankRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ChapterModel>> getChaptersBySubject(int subjectId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/subjects/$subjectId/chapters',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => ChapterModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load chapters',
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
  Future<ChapterModel> getChapterById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/chapters/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ChapterModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load chapter',
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
  Future<ChapterModel> createChapter(
    int subjectId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.questionBank}/subjects/$subjectId/chapters',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ChapterModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create chapter',
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
  Future<ChapterModel> updateChapter(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.questionBank}/chapters/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ChapterModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update chapter',
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
  Future<void> deleteChapter(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.questionBank}/chapters/$id',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete chapter',
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
  Future<List<PassageModel>> getPassagesByChapter(int chapterId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/chapters/$chapterId/passages',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => PassageModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load passages',
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
  Future<PassageModel> getPassageById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/passages/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PassageModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load passage',
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
  Future<PassageModel> createPassage(
    int chapterId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.questionBank}/chapters/$chapterId/passages',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PassageModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create passage',
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
  Future<PassageModel> updatePassage(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.questionBank}/passages/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return PassageModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update passage',
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
  Future<void> deletePassage(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.questionBank}/passages/$id',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete passage',
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
  Future<List<QuestionModel>> getQuestionsByPassage(int passageId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/passages/$passageId/questions',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => QuestionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load questions',
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
  Future<List<QuestionModel>> getQuestionsByChapter(int chapterId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/chapters/$chapterId/questions',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => QuestionModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load questions',
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
  Future<QuestionModel> getQuestionById(int id) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.questionBank}/questions/$id',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return QuestionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load question',
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
  Future<QuestionModel> createQuestion(Map<String, dynamic> data) async {
    try {
      // Determine endpoint based on whether passageId or chapterId is provided
      String endpoint;
      if (data['passageId'] != null) {
        endpoint =
            '${ApiConstants.questionBank}/passages/${data['passageId']}/questions';
      } else if (data['chapterId'] != null) {
        endpoint =
            '${ApiConstants.questionBank}/chapters/${data['chapterId']}/questions';
      } else {
        throw ServerException(
          message: 'Either passageId or chapterId must be provided',
        );
      }

      final response = await _apiClient.post(endpoint, data: data);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return QuestionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create question',
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
  Future<QuestionModel> updateQuestion(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.questionBank}/questions/$id',
        data: data,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return QuestionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update question',
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
  Future<void> deleteQuestion(int id) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.questionBank}/questions/$id',
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete question',
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
