class EmailValidator {
  static final _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValid(String email) => _emailRegExp.hasMatch(email.trim());

  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!isValid(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
