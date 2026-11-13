/// Central place for the backend address used by every API service.
///
/// Change [baseUrl] to match where the Spring Boot server runs:
/// - Chrome or Windows desktop: `http://localhost:8080/api`
/// - Android emulator: `http://10.0.2.2:8080/api`
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'http://localhost:8080/api';
}
