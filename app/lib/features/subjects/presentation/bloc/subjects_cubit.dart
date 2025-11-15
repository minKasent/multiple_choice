import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/subjects_repository.dart';
import 'subjects_state.dart';

@injectable
class SubjectsCubit extends Cubit<SubjectsState> {
  final SubjectsRepository _repository;

  SubjectsCubit(this._repository) : super(const SubjectsState.initial());

  Future<void> loadSubjects() async {
    emit(const SubjectsState.loading());

    final result = await _repository.getAllSubjects();

    result.fold(
      (failure) => emit(SubjectsState.error(failure.message)),
      (subjects) => emit(SubjectsState.loaded(subjects)),
    );
  }

  Future<void> searchSubjects(String keyword) async {
    if (keyword.isEmpty) {
      await loadSubjects();
      return;
    }

    emit(const SubjectsState.loading());

    final result = await _repository.searchSubjects(keyword);

    result.fold(
      (failure) => emit(SubjectsState.error(failure.message)),
      (subjects) => emit(SubjectsState.loaded(subjects)),
    );
  }

  Future<void> createSubject(Map<String, dynamic> data) async {
    emit(const SubjectsState.loading());

    final result = await _repository.createSubject(data);

    result.fold(
      (failure) => emit(SubjectsState.error(failure.message)),
      (subject) {
        emit(SubjectsState.created(subject));
        loadSubjects(); // Reload list
      },
    );
  }

  Future<void> updateSubject(int id, Map<String, dynamic> data) async {
    emit(const SubjectsState.loading());

    final result = await _repository.updateSubject(id, data);

    result.fold(
      (failure) => emit(SubjectsState.error(failure.message)),
      (subject) {
        emit(SubjectsState.updated(subject));
        loadSubjects(); // Reload list
      },
    );
  }

  Future<void> deleteSubject(int id) async {
    emit(const SubjectsState.loading());

    final result = await _repository.deleteSubject(id);

    result.fold(
      (failure) => emit(SubjectsState.error(failure.message)),
      (_) {
        emit(const SubjectsState.deleted());
        loadSubjects(); // Reload list
      },
    );
  }
}

