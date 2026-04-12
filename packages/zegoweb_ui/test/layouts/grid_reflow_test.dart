import 'package:flutter_test/flutter_test.dart';
import 'package:zegoweb_ui/src/layouts/grid_reflow.dart';

void main() {
  group('gridReflow', () {
    test('1 participant → [1]', () => expect(gridReflow(1), [1]));
    test('2 participants → [2]', () => expect(gridReflow(2), [2]));
    test('3 participants → [3]', () => expect(gridReflow(3), [3]));
    test('4 participants → [2, 2]', () => expect(gridReflow(4), [2, 2]));
    test('5 participants → [3, 2]', () => expect(gridReflow(5), [3, 2]));
    test('6 participants → [3, 3]', () => expect(gridReflow(6), [3, 3]));
    test('7 participants → [4, 3]', () => expect(gridReflow(7), [4, 3]));
    test('8 participants → [4, 4]', () => expect(gridReflow(8), [4, 4]));
    test('9 participants → [3, 3, 3]', () => expect(gridReflow(9), [3, 3, 3]));
    test(
        '10 participants → [4, 3, 3]', () => expect(gridReflow(10), [4, 3, 3]));
    test(
        '11 participants → [4, 4, 3]', () => expect(gridReflow(11), [4, 4, 3]));
    test(
        '12 participants → [4, 4, 4]', () => expect(gridReflow(12), [4, 4, 4]));
    test('0 participants → []', () => expect(gridReflow(0), <int>[]));

    test('no row has only 1 tile (for n >= 2)', () {
      for (int n = 2; n <= 20; n++) {
        final rows = gridReflow(n);
        for (final row in rows) {
          expect(row, greaterThanOrEqualTo(2),
              reason: 'n=$n produced a row with $row tile(s): $rows');
        }
      }
    });

    test('sum of all rows equals n', () {
      for (int n = 0; n <= 20; n++) {
        final rows = gridReflow(n);
        final sum = rows.fold<int>(0, (a, b) => a + b);
        expect(sum, n, reason: 'n=$n: rows=$rows sum=$sum');
      }
    });
  });
}
