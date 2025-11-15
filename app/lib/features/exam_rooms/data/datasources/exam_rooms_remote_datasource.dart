import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exam_room_model.dart';

abstract class ExamRoomsRemoteDataSource {
  Future<List<ExamRoomModel>> getAllExamRooms({
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'asc',
  });
  Future<ExamRoomModel> getExamRoomById(int id);
  Future<ExamRoomModel> getExamRoomByCode(String code);
  Future<ExamRoomModel> createExamRoom(Map<String, dynamic> request);
  Future<ExamRoomModel> updateExamRoom(int id, Map<String, dynamic> request);
  Future<void> deleteExamRoom(int id);
  Future<ExamRoomModel> assignProctors(int examRoomId, List<int> proctorIds);
  Future<ExamRoomModel> removeProctor(int examRoomId, int proctorId);
}

@LazySingleton(as: ExamRoomsRemoteDataSource)
class ExamRoomsRemoteDataSourceImpl implements ExamRoomsRemoteDataSource {
  final ApiClient _apiClient;

  ExamRoomsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ExamRoomModel>> getAllExamRooms({
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'asc',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.examRooms,
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'direction': direction,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final content = data['content'] as List;
        return content.map((json) => ExamRoomModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam rooms',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam rooms: $e');
    }
  }

  @override
  Future<ExamRoomModel> getExamRoomById(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.examRooms}/$id');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam room',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam room: $e');
    }
  }

  @override
  Future<ExamRoomModel> getExamRoomByCode(String code) async {
    try {
      final response = await _apiClient.get(
        '${ApiConstants.examRooms}/code/$code',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load exam room',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error loading exam room: $e');
    }
  }

  @override
  Future<ExamRoomModel> createExamRoom(Map<String, dynamic> request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.examRooms,
        data: request,
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create exam room',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error creating exam room: $e');
    }
  }

  @override
  Future<ExamRoomModel> updateExamRoom(
    int id,
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConstants.examRooms}/$id',
        data: request,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update exam room',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error updating exam room: $e');
    }
  }

  @override
  Future<void> deleteExamRoom(int id) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.examRooms}/$id');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete exam room',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error deleting exam room: $e');
    }
  }

  @override
  Future<ExamRoomModel> assignProctors(
    int examRoomId,
    List<int> proctorIds,
  ) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.examRooms}/$examRoomId/proctors',
        data: {'proctorIds': proctorIds},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to assign proctors',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error assigning proctors: $e');
    }
  }

  @override
  Future<ExamRoomModel> removeProctor(int examRoomId, int proctorId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiConstants.examRooms}/$examRoomId/proctors/$proctorId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExamRoomModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to remove proctor',
        );
      }
    } catch (e) {
      throw ServerException(message: 'Error removing proctor: $e');
    }
  }
}
