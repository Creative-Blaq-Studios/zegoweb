import 'dart:math';

/// Returns the number of tiles per row for [n] participants in a video grid.
///
/// The algorithm produces a balanced, Google Meet-style layout:
/// 1. Compute `rows = floor(sqrt(n))`.
/// 2. Compute `cols = ceil(n / rows)`.
/// 3. If the last row of an even distribution would have only 1 tile,
///    increment `cols` (which reduces `rows`) and retry.
/// 4. Distribute tiles evenly so the difference between any two rows is at
///    most 1, filling earlier rows first.
///
/// Edge cases: `0` → `[]`, `1` → `[1]`.
List<int> gridReflow(int n) {
  if (n <= 0) return [];
  if (n == 1) return [1];

  // Compute the initial number of rows using floor(sqrt(n)).
  int rows = sqrt(n).floor();

  // Derive the column count from the row count.
  int cols = (n / rows).ceil();

  // Guard: if the evenly-distributed last row would be a lonely single tile,
  // increment cols (which may reduce totalRows) and retry.
  while (true) {
    final int totalRows = (n / cols).ceil();
    final int base = n ~/ totalRows;
    // rows getting base+1 tiles
    // rows getting base tiles: totalRows - extras
    // The last row always gets `base` tiles (since extras rows come first).
    if (base == 1) {
      // Single-tile rows detected — widen the grid.
      cols++;
    } else {
      rows = totalRows;
      break;
    }
  }

  // Distribute n tiles across `rows` rows: extras rows get (base+1), the
  // rest get base. Earlier rows receive the extra tile.
  final int base = n ~/ rows;
  final int extras = n % rows;

  return List<int>.generate(rows, (i) => i < extras ? base + 1 : base);
}
