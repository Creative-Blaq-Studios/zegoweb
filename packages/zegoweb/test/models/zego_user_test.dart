// packages/zegoweb/test/models/zego_user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb/src/models/zego_user.dart';

void main() {
  group('ZegoUser', () {
    test('stores userId and userName', () {
      const user = ZegoUser(userId: 'u1', userName: 'Alice');
      expect(user.userId, 'u1');
      expect(user.userName, 'Alice');
    });

    test('value equality: same fields are equal', () {
      const a = ZegoUser(userId: 'u1', userName: 'Alice');
      const b = ZegoUser(userId: 'u1', userName: 'Alice');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different userId is not equal', () {
      const a = ZegoUser(userId: 'u1', userName: 'Alice');
      const b = ZegoUser(userId: 'u2', userName: 'Alice');
      expect(a, isNot(equals(b)));
    });

    test('value equality: different userName is not equal', () {
      const a = ZegoUser(userId: 'u1', userName: 'Alice');
      const b = ZegoUser(userId: 'u1', userName: 'Bob');
      expect(a, isNot(equals(b)));
    });

    test('toString includes both fields', () {
      const user = ZegoUser(userId: 'u1', userName: 'Alice');
      expect(user.toString(), contains('u1'));
      expect(user.toString(), contains('Alice'));
    });
  });
}
