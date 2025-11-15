import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/google_signin_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AuthRepository _authRepository;
  final GoogleSignIn _googleSignIn;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getProfileUseCase,
    this._googleSignInUseCase,
    this._authRepository,
  ) : _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']),
      super(const AuthState.initial());

  Future<void> login(String email, String password) async {
    emit(const AuthState.loading());

    final result = await _loginUseCase(email, password);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (authResponse) => emit(AuthState.authenticated(authResponse.user)),
    );
  }

  Future<void> register(Map<String, dynamic> data) async {
    emit(const AuthState.loading());

    final result = await _registerUseCase(data);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (authResponse) => emit(AuthState.authenticated(authResponse.user)),
    );
  }

  Future<void> logout() async {
    emit(const AuthState.loading());

    try {
      // Sign out from Google if user was signed in with Google
      try {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
      } catch (e) {
        // Ignore error if user wasn't signed in with Google
      }

      // Clear all Hive boxes to remove cached data
      try {
        if (Hive.isBoxOpen(StorageConstants.userBox)) {
          await Hive.box(StorageConstants.userBox).clear();
        }
        if (Hive.isBoxOpen(StorageConstants.cacheBox)) {
          await Hive.box(StorageConstants.cacheBox).clear();
        }
        if (Hive.isBoxOpen(StorageConstants.settingsBox)) {
          await Hive.box(StorageConstants.settingsBox).clear();
        }
      } catch (e) {
        // Ignore Hive errors
      }

      // Clear local cache through repository
      final result = await _logoutUseCase();

      result.fold(
        (failure) {
          // Even if logout fails on server, still clear local state
          emit(const AuthState.unauthenticated());
        },
        (_) => emit(const AuthState.unauthenticated()),
      );
    } catch (e) {
      // Ensure we always emit unauthenticated state even if something fails
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> getProfile() async {
    emit(const AuthState.loading());

    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        // If unauthorized, emit unauthenticated state to trigger navigation to login
        if (failure is UnauthorizedFailure) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.error(failure.message));
        }
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());

    try {
      // Sign out first to allow user to select different account
      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        emit(const AuthState.error('Google sign in cancelled'));
        return;
      }

      final authentication = await account.authentication;
      final accessToken = authentication.accessToken;

      if (accessToken == null) {
        emit(const AuthState.error('Failed to get Google access token'));
        return;
      }

      final result = await _googleSignInUseCase(accessToken);

      result.fold(
        (failure) => emit(AuthState.error(failure.message)),
        (authResponse) => emit(AuthState.authenticated(authResponse.user)),
      );
    } catch (e) {
      emit(AuthState.error('Google sign in failed: ${e.toString()}'));
    }
  }

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    await getProfile();
  }

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  /// Sign out from Google account only
  /// Useful when user wants to switch Google account
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> updateProfile(int userId, Map<String, dynamic> data) async {
    emit(const AuthState.loading());

    final result = await _authRepository.updateProfile(userId, data);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> changePassword(int userId, Map<String, dynamic> data) async {
    emit(const AuthState.loading());

    final result = await _authRepository.changePassword(userId, data);

    result.fold((failure) => emit(AuthState.error(failure.message)), (_) {
      // Password changed successfully, get profile again
      getProfile();
    });
  }
}
