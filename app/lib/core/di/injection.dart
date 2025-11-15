import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  getIt.registerLazySingleton(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  getIt.registerLazySingleton(() => Connectivity());

  // Initialize Hive
  await Hive.initFlutter();
  final userBox = await Hive.openBox(StorageConstants.userBox);
  final cacheBox = await Hive.openBox(StorageConstants.cacheBox);
  final settingsBox = await Hive.openBox(StorageConstants.settingsBox);

  getIt.registerLazySingleton(() => userBox, instanceName: 'userBox');
  getIt.registerLazySingleton(() => cacheBox, instanceName: 'cacheBox');
  getIt.registerLazySingleton(() => settingsBox, instanceName: 'settingsBox');

  // Initialize generated dependencies
  getIt.init();
}

Future<void> resetDependencies() async {
  await getIt.reset();
  await configureDependencies();
}
