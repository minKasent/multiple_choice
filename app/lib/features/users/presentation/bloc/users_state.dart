import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/user_model.dart';

part 'users_state.freezed.dart';

@freezed
class UsersState with _$UsersState {
  const factory UsersState.initial() = _Initial;
  const factory UsersState.loading() = _Loading;
  const factory UsersState.loaded(List<UserModel> users) = _Loaded;
  const factory UsersState.created(UserModel user) = _Created;
  const factory UsersState.updated(UserModel user) = _Updated;
  const factory UsersState.deleted() = _Deleted;
  const factory UsersState.statusToggled() = _StatusToggled;
  const factory UsersState.error(String message) = _Error;
}
