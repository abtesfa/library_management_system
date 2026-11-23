import 'package:flutter/foundation.dart';

/// Central place for the backend address used by every API service.
///
/// Override the address with `--dart-define=API_BASE_URL=...` when the backend
/// runs on another machine, such as a physical phone's host computer.
class ApiConfig {
  const ApiConfig._();

  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }
    return 'http://localhost:8080/api';
  }
}
