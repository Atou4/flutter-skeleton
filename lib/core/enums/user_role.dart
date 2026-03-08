enum UserRole {
  admin,
  user;

  String get displayName {
    return switch (this) {
      UserRole.admin => 'Admin',
      UserRole.user => 'User',
    };
  }

  String get value {
    return switch (this) {
      UserRole.admin => 'admin',
      UserRole.user => 'user',
    };
  }

  static UserRole fromString(String value) {
    return switch (value.toLowerCase()) {
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      _ => throw ArgumentError('Invalid user role: $value'),
    };
  }
}
