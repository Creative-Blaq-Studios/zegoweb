import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_prebuilt/src/zego_prebuilt_user.dart';

void main() {
  group('ZegoPrebuiltUser', () {
    test('stores userId and optional userName', () {
      const user = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      expect(user.userId, 'u1');
      expect(user.userName, 'Alice');
    });

    test('userName defaults to null', () {
      const user = ZegoPrebuiltUser(userId: 'u1');
      expect(user.userName, isNull);
    });

    test('value equality: same fields are equal', () {
      const a = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      const b = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different userId is not equal', () {
      const a = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      const b = ZegoPrebuiltUser(userId: 'u2', userName: 'Alice');
      expect(a, isNot(equals(b)));
    });

    test('value equality: different userName is not equal', () {
      const a = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      const b = ZegoPrebuiltUser(userId: 'u1', userName: 'Bob');
      expect(a, isNot(equals(b)));
    });

    test('toString includes userId', () {
      const user = ZegoPrebuiltUser(userId: 'u1', userName: 'Alice');
      expect(user.toString(), contains('u1'));
      expect(user.toString(), contains('Alice'));
    });
  });
}
