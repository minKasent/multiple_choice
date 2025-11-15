import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/subject_model.dart';

part 'subjects_state.freezed.dart';

@freezed
class SubjectsState with _$SubjectsState {
  const factory SubjectsState.initial() = _Initial;
  const factory SubjectsState.loading() = _Loading;
  const factory SubjectsState.loaded(List<SubjectModel> subjects) = _Loaded;
  const factory SubjectsState.created(SubjectModel subject) = _Created;
  const factory SubjectsState.updated(SubjectModel subject) = _Updated;
  const factory SubjectsState.deleted() = _Deleted;
  const factory SubjectsState.error(String message) = _Error;
}

