/// Thrown by data sources when the backend answers with an error.
///
/// [message] is the text that should be shown to the user (taken from the
/// server's response). Network failures and timeouts are NOT wrapped in this
/// type, so callers can tell "server said no" apart from "could not connect".
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
