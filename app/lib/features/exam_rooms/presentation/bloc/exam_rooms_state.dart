import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/exam_room_model.dart';

part 'exam_rooms_state.freezed.dart';

@freezed
class ExamRoomsState with _$ExamRoomsState {
  const factory ExamRoomsState.initial() = _Initial;
  const factory ExamRoomsState.loading() = _Loading;
  const factory ExamRoomsState.examRoomsLoaded(List<ExamRoomModel> examRooms) = _ExamRoomsLoaded;
  const factory ExamRoomsState.examRoomLoaded(ExamRoomModel examRoom) = _ExamRoomLoaded;
  const factory ExamRoomsState.examRoomCreated(ExamRoomModel examRoom) = _ExamRoomCreated;
  const factory ExamRoomsState.examRoomUpdated(ExamRoomModel examRoom) = _ExamRoomUpdated;
  const factory ExamRoomsState.examRoomDeleted() = _ExamRoomDeleted;
  const factory ExamRoomsState.proctorsAssigned(ExamRoomModel examRoom) = _ProctorsAssigned;
  const factory ExamRoomsState.proctorRemoved(ExamRoomModel examRoom) = _ProctorRemoved;
  const factory ExamRoomsState.error(String message) = _Error;
}

