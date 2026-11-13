/// Condition a book can be returned in.
class BookCondition {
  const BookCondition._();

  static const Set<String> allowed = {
    'GOOD',
    'MINOR_DAMAGE',
    'LOST',
  };

  /// Turns a label such as "Minor damage" into the backend value
  /// `MINOR_DAMAGE`.
  static String normalize(String condition) =>
      condition.toUpperCase().replaceAll(' ', '_');

  static bool isValid(String normalizedCondition) =>
      allowed.contains(normalizedCondition);
}
