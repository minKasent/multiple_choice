import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/users_repository.dart';
import 'users_state.dart';

@injectable
class UsersCubit extends Cubit<UsersState> {
  final UsersRepository _repository;

  UsersCubit(this._repository) : super(const UsersState.initial());

  Future<void> loadUsers({int page = 0, int size = 20}) async {
    emit(const UsersState.loading());

    final result = await _repository.getAllUsers(page: page, size: size);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (users) => emit(UsersState.loaded(users)),
    );
  }

  Future<void> loadUsersByRole(String roleName) async {
    emit(const UsersState.loading());

    final result = await _repository.getUsersByRole(roleName);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (users) => emit(UsersState.loaded(users)),
    );
  }

  Future<void> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      await loadUsers();
      return;
    }

    emit(const UsersState.loading());

    final result = await _repository.searchUsers(keyword);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (users) => emit(UsersState.loaded(users)),
    );
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    emit(const UsersState.loading());

    final result = await _repository.createUser(data);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (user) {
        emit(UsersState.created(user));
        loadUsers(); // Reload list
      },
    );
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    emit(const UsersState.loading());

    final result = await _repository.updateUser(id, data);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (user) {
        emit(UsersState.updated(user));
        loadUsers(); // Reload list
      },
    );
  }

  Future<void> deleteUser(int id) async {
    emit(const UsersState.loading());

    final result = await _repository.deleteUser(id);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (_) {
        emit(const UsersState.deleted());
        loadUsers(); // Reload list
      },
    );
  }

  Future<void> toggleUserStatus(int id) async {
    emit(const UsersState.loading());

    final result = await _repository.toggleUserStatus(id);

    result.fold(
      (failure) => emit(UsersState.error(failure.message)),
      (_) {
        emit(const UsersState.statusToggled());
        loadUsers(); // Reload list
      },
    );
  }
}
