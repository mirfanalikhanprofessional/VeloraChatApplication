import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_chat_application/core/storage/user_session_storage.dart';
import 'package:test_chat_application/domain/entities/app_user.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage secure;
  late UserSessionStorage storage;
  final store = <String, String>{};

  setUp(() {
    secure = MockFlutterSecureStorage();
    store.clear();
    when(() => secure.read(key: any(named: 'key'))).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return store[key];
    });
    when(
      () => secure.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      store[key] = value;
    });
    when(() => secure.delete(key: any(named: 'key'))).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      store.remove(key);
    });
    storage = UserSessionStorage(storage: secure);
  });

  group('welcome seen', () {
    test('hasSeenWelcome is false by default', () async {
      expect(await storage.hasSeenWelcome(), isFalse);
    });

    test('markWelcomeSeen persists first-launch flag', () async {
      await storage.markWelcomeSeen();
      expect(await storage.hasSeenWelcome(), isTrue);
    });

    test('clearAll does not clear welcome seen flag', () async {
      await storage.markWelcomeSeen();
      await storage.saveRememberMe(rememberMe: true, email: 'a@b.com');
      await storage.clearAll();

      expect(await storage.hasSeenWelcome(), isTrue);
      expect(await storage.isRememberMeEnabled(), isFalse);
    });
  });

  group('session only when remember me', () {
    const user = AppUser(
      uid: 'u1',
      email: 'a@b.com',
      displayName: 'Alex',
    );

    test('saveSession is a no-op when remember me is off', () async {
      await storage.saveRememberMe(rememberMe: false, email: 'a@b.com');
      await storage.saveSession(user);

      expect(await storage.readSession(), isNull);
      expect(store.containsKey('user_session'), isFalse);
    });

    test('saveSession persists user when remember me is on', () async {
      await storage.saveRememberMe(rememberMe: true, email: 'a@b.com');
      await storage.saveSession(user);

      final cached = await storage.readSession();
      expect(cached, isNotNull);
      expect(cached!.uid, 'u1');
      expect(cached.email, 'a@b.com');
    });

    test('readSession returns null when remember me is off', () async {
      await storage.saveRememberMe(rememberMe: true, email: 'a@b.com');
      await storage.saveSession(user);
      await storage.saveRememberMe(rememberMe: false, email: 'a@b.com');

      expect(await storage.readSession(), isNull);
    });
  });
}
