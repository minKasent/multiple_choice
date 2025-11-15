import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<bool> isLoggedIn();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl(
    this._secureStorage,
    this._sharedPreferences,
  );

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.accessToken,
        value: accessToken,
      );
      await _secureStorage.write(
        key: StorageConstants.refreshToken,
        value: refreshToken,
      );
      await _sharedPreferences.setBool(StorageConstants.isLoggedIn, true);
    } catch (e) {
      throw CacheException(message: 'Failed to cache tokens');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get access token');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to get refresh token');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _secureStorage.write(
        key: StorageConstants.userId,
        value: user.id.toString(),
      );
      await _secureStorage.write(
        key: StorageConstants.userEmail,
        value: user.email,
      );
      await _secureStorage.write(
        key: StorageConstants.userRole,
        value: user.role.name,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userId = await _secureStorage.read(key: StorageConstants.userId);
      if (userId == null) return null;

      // Note: This is a simplified version. In a real app, you'd cache the full user object
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear all secure storage
      await _secureStorage.deleteAll();
      
      // Clear all shared preferences related to auth
      await _sharedPreferences.remove(StorageConstants.isLoggedIn);
      await _sharedPreferences.remove(StorageConstants.userId);
      await _sharedPreferences.remove(StorageConstants.userEmail);
      await _sharedPreferences.remove(StorageConstants.userRole);
      
      // Clear all Hive boxes
      try {
        if (Hive.isBoxOpen(StorageConstants.userBox)) {
          await Hive.box(StorageConstants.userBox).clear();
        }
        if (Hive.isBoxOpen(StorageConstants.cacheBox)) {
          await Hive.box(StorageConstants.cacheBox).clear();
        }
      } catch (e) {
        // Ignore Hive errors if boxes are not open
      }
      
      // Clear all keys to ensure clean slate
      await _sharedPreferences.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = _sharedPreferences.getBool(
            StorageConstants.isLoggedIn,
          ) ??
          false;
      final token = await getAccessToken();
      return isLoggedIn && token != null;
    } catch (e) {
      return false;
    }
  }
}

