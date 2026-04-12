import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/zego_participant.dart';

void main() {
  group('ZegoParticipant', () {
    test('stores all fields', () {
      const p = ZegoParticipant(
          userId: 'u1',
          userName: 'Alice',
          isMuted: true,
          isCameraOff: false,
          isLocal: true);
      expect(p.userId, 'u1');
      expect(p.userName, 'Alice');
      expect(p.stream, isNull);
      expect(p.isMuted, isTrue);
      expect(p.isCameraOff, isFalse);
      expect(p.isLocal, isTrue);
    });

    test('defaults: isMuted=false, isCameraOff=false, isLocal=false', () {
      const p = ZegoParticipant(userId: 'u1');
      expect(p.isMuted, isFalse);
      expect(p.isCameraOff, isFalse);
      expect(p.isLocal, isFalse);
      expect(p.userName, isNull);
      expect(p.stream, isNull);
    });

    test('value equality: same fields are equal', () {
      const a = ZegoParticipant(userId: 'u1', userName: 'Alice');
      const b = ZegoParticipant(userId: 'u1', userName: 'Alice');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality: different userId is not equal', () {
      const a = ZegoParticipant(userId: 'u1');
      const b = ZegoParticipant(userId: 'u2');
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates a new instance with changed fields', () {
      const p = ZegoParticipant(userId: 'u1', userName: 'Alice');
      final updated = p.copyWith(isMuted: true, isCameraOff: true);
      expect(updated.userId, 'u1');
      expect(updated.userName, 'Alice');
      expect(updated.isMuted, isTrue);
      expect(updated.isCameraOff, isTrue);
    });

    test('toString includes userId', () {
      const p = ZegoParticipant(userId: 'u1', userName: 'Alice');
      expect(p.toString(), contains('u1'));
    });

    test('initials returns first letters of name parts', () {
      const p = ZegoParticipant(userId: 'u1', userName: 'Alice Bob');
      expect(p.initials, 'AB');
    });

    test('initials returns userId first char when no userName', () {
      const p = ZegoParticipant(userId: 'user-1');
      expect(p.initials, 'U');
    });

    test('initials handles single name', () {
      const p = ZegoParticipant(userId: 'u1', userName: 'Alice');
      expect(p.initials, 'A');
    });
  });
}
