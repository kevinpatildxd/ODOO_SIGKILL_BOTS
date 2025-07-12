import 'package:dio/dio.dart';
import 'package:stackit_frontend/config/app_config.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;
}
