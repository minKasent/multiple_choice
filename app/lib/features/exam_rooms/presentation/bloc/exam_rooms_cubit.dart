import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/exam_rooms_repository.dart';
import 'exam_rooms_state.dart';

@injectable
class ExamRoomsCubit extends Cubit<ExamRoomsState> {
  final ExamRoomsRepository _repository;

  ExamRoomsCubit(this._repository) : super(const ExamRoomsState.initial());

  Future<void> loadExamRooms({
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'asc',
  }) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.getAllExamRooms(
      page: page,
      size: size,
      sortBy: sortBy,
      direction: direction,
    );

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRooms) => emit(ExamRoomsState.examRoomsLoaded(examRooms)),
    );
  }

  Future<void> loadExamRoomById(int id) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.getExamRoomById(id);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.examRoomLoaded(examRoom)),
    );
  }

  Future<void> loadExamRoomByCode(String code) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.getExamRoomByCode(code);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.examRoomLoaded(examRoom)),
    );
  }

  Future<void> createExamRoom(Map<String, dynamic> request) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.createExamRoom(request);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.examRoomCreated(examRoom)),
    );
  }

  Future<void> updateExamRoom(int id, Map<String, dynamic> request) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.updateExamRoom(id, request);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.examRoomUpdated(examRoom)),
    );
  }

  Future<void> deleteExamRoom(int id) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.deleteExamRoom(id);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (_) => emit(const ExamRoomsState.examRoomDeleted()),
    );
  }

  Future<void> assignProctors(int examRoomId, List<int> proctorIds) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.assignProctors(examRoomId, proctorIds);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.proctorsAssigned(examRoom)),
    );
  }

  Future<void> removeProctor(int examRoomId, int proctorId) async {
    emit(const ExamRoomsState.loading());

    final result = await _repository.removeProctor(examRoomId, proctorId);

    result.fold(
      (failure) => emit(ExamRoomsState.error(failure.message)),
      (examRoom) => emit(ExamRoomsState.proctorRemoved(examRoom)),
    );
  }
}

