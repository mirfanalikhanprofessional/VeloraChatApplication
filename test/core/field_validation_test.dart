import 'package:flutter_test/flutter_test.dart';
import 'package:test_chat_application/core/utils/field_validation.dart';

class _Validators with FieldValidation {}

void main() {
  final validators = _Validators();

  group('FieldValidation', () {
    test('validateEmail rejects empty and invalid values', () {
      expect(validators.validateEmail(null), 'Email is required');
      expect(validators.validateEmail(''), 'Email is required');
      expect(validators.validateEmail('plain'), 'Enter a valid email');
      expect(validators.validateEmail('a@b.com'), isNull);
    });

    test('validatePassword enforces min length when required', () {
      expect(validators.validatePassword(null), 'Password is required');
      expect(
        validators.validatePassword('123'),
        'Password must be at least 6 characters',
      );
      expect(validators.validatePassword('123456'), isNull);
      expect(
        validators.validatePassword('1', requireMinLength: false),
        isNull,
      );
    });

    test('validateDisplayName requires non-empty name', () {
      expect(
        validators.validateDisplayName('  '),
        'Display name is required',
      );
      expect(validators.validateDisplayName('Irfan'), isNull);
    });
  });
}
