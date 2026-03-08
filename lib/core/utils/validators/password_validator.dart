class PasswordValidator {
  static const int minLength = 8;

  static bool isValid(String password) => password.length >= minLength;

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
}
