import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/exam_room_model.dart';

abstract class ExamRoomsRepository {
  Future<Either<Failure, List<ExamRoomModel>>> getAllExamRooms({
    int page = 0,
    int size = 20,
    String sortBy = 'name',
    String direction = 'asc',
  });
  Future<Either<Failure, ExamRoomModel>> getExamRoomById(int id);
  Future<Either<Failure, ExamRoomModel>> getExamRoomByCode(String code);
  Future<Either<Failure, ExamRoomModel>> createExamRoom(
    Map<String, dynamic> request,
  );
  Future<Either<Failure, ExamRoomModel>> updateExamRoom(
    int id,
    Map<String, dynamic> request,
  );
  Future<Either<Failure, void>> deleteExamRoom(int id);
  Future<Either<Failure, ExamRoomModel>> assignProctors(
    int examRoomId,
    List<int> proctorIds,
  );
  Future<Either<Failure, ExamRoomModel>> removeProctor(
    int examRoomId,
    int proctorId,
  );
}
