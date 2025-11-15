import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_constants.dart';
import 'dart:developer' as developer;

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;

  AuthInterceptor(this._secureStorage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Danh sách các endpoint không cần token
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/google',
      '/auth/refresh',
    ];

    // Kiểm tra xem request có phải là public endpoint không
    final isPublicEndpoint = publicEndpoints.any(
      (endpoint) => options.path.contains(endpoint),
    );

    // Chỉ thêm token nếu không phải public endpoint
    if (!isPublicEndpoint) {
      final token = await _secureStorage.read(
        key: StorageConstants.accessToken,
      );

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        developer.log(
          'Token added to request: ${token.substring(0, 20)}...',
          name: 'AuthInterceptor',
        );
      } else {
        developer.log(
          'No token found for protected endpoint: ${options.path}',
          name: 'AuthInterceptor',
        );
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Danh sách các endpoint không nên refresh token
      final publicEndpoints = [
        '/auth/login',
        '/auth/register',
        '/auth/google',
        '/auth/refresh',
      ];

      // Kiểm tra xem request có phải là public endpoint không
      final isPublicEndpoint = publicEndpoints.any(
        (endpoint) => err.requestOptions.path.contains(endpoint),
      );

      // Nếu là public endpoint (login fail chẳng hạn), không thử refresh token
      if (isPublicEndpoint) {
        developer.log(
          '401 from public endpoint, skipping token refresh',
          name: 'AuthInterceptor',
        );
        return handler.next(err);
      }

      developer.log('401 Unauthorized error received', name: 'AuthInterceptor');

      // Try to refresh token
      final refreshToken = await _secureStorage.read(
        key: StorageConstants.refreshToken,
      );

      if (refreshToken != null) {
        developer.log(
          'Attempting to refresh token...',
          name: 'AuthInterceptor',
        );
        try {
          final response = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            developer.log(
              'Token refreshed successfully',
              name: 'AuthInterceptor',
            );

            // Save new tokens
            await _secureStorage.write(
              key: StorageConstants.accessToken,
              value: newAccessToken,
            );
            await _secureStorage.write(
              key: StorageConstants.refreshToken,
              value: newRefreshToken,
            );

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          developer.log('Refresh token failed: $e', name: 'AuthInterceptor');
          // Refresh token failed, logout user
          await _secureStorage.deleteAll();
          return handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              error: 'Session expired. Please login again.',
              type: DioExceptionType.badResponse,
              response: err.response,
            ),
          );
        }
      } else {
        developer.log('No refresh token found', name: 'AuthInterceptor');
        // No refresh token, clear storage and let the app handle logout
        await _secureStorage.deleteAll();
        // Don't reject immediately - let the error propagate so app can handle it
        // The app should check auth state and navigate to login if needed
      }
    }
    return handler.next(err);
  }
}
