import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

/// Quản lý việc clear cache toàn bộ app
class CacheManager {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  CacheManager(this._secureStorage, this._sharedPreferences);

  /// Clear tất cả cache và storage khi logout
  Future<void> clearAllCache() async {
    try {
      // 1. Clear Secure Storage (tokens, user info)
      await _secureStorage.deleteAll();

      // 2. Clear SharedPreferences
      await _sharedPreferences.clear();

      // 3. Clear all Hive boxes
      await _clearHiveBoxes();
    } catch (e) {
      // Log error but don't throw - we want to logout anyway
      print('Error clearing cache: $e');
    }
  }

  /// Clear tất cả Hive boxes
  Future<void> _clearHiveBoxes() async {
    try {
      // Clear user box
      if (Hive.isBoxOpen(StorageConstants.userBox)) {
        await Hive.box(StorageConstants.userBox).clear();
      }

      // Clear cache box
      if (Hive.isBoxOpen(StorageConstants.cacheBox)) {
        await Hive.box(StorageConstants.cacheBox).clear();
      }

      // Clear settings box
      if (Hive.isBoxOpen(StorageConstants.settingsBox)) {
        await Hive.box(StorageConstants.settingsBox).clear();
      }
    } catch (e) {
      print('Error clearing Hive boxes: $e');
    }
  }

  /// Check nếu có token
  Future<bool> hasValidToken() async {
    try {
      final token = await _secureStorage.read(
        key: StorageConstants.accessToken,
      );
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

