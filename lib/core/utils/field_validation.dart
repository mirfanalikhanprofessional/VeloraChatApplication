/// Shared form field validators for auth and profile screens.
mixin FieldValidation {
  String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(
    String? value, {
    int minLength = 6,
    bool requireMinLength = true,
  }) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (requireMinLength && value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  String? validateDisplayName(String? value) {
    return validateRequired(value, fieldName: 'Display name');
  }
}
