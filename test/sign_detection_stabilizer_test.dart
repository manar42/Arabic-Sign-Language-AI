import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/core/sign_detection_stabilizer.dart';

/// Feeds frames sequentially and returns the stabilizer result after each.
List<String?> feed(SignDetectionStabilizer s, List<(String?, double)> frames) {
  return [
    for (final (token, confidence) in frames) s.update(token, confidence),
  ];
}

void main() {
  group('SignDetectionStabilizer', () {
    // Defaults under test: window 9, minConfidence 0.60, minVotes 5,
    // latest entry must agree with the winner.
    test('steady gesture becomes accepted only after enough agreeing frames',
        () {
      final s = SignDetectionStabilizer();
      final results = feed(
        s,
        List.filled(6, (('A'), 0.90)),
      );
      expect(results[0], isNull);
      expect(results[3], isNull);
      expect(results[4], 'A');
      expect(results[5], 'A');
    });

    test('single noisy frame cannot flip the accepted letter', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      // One stray confident-looking B frame among solid A history.
      expect(s.update('B', 0.95), isNull);
      // History restores acceptance on the very next agreeing frame.
      expect(s.update('A', 0.90), 'A');
    });

    test('A -> B transitions within a bounded number of frames', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      final results = feed(
        s,
        List.filled(9, (('B'), 0.90)),
      );
      // Transitional majority splits are rejected instead of flickering.
      expect(results.take(4), everyElement(isNull));
      expect(results[4], 'B');
      expect(results[8], 'B');
    });

    test('losing the hand decays acceptance immediately (never sticky)', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      // First hand-less frame must invalidate the stale letter even though
      // old A entries remain inside the rolling window.
      expect(s.update(null, 0), isNull);
      // And it stays invalidated until a new gesture earns its own votes.
      expect(s.update('B', 0.90), isNull);
      expect(s.update('B', 0.90), isNull);
    });

    test('low-confidence frames behave like non-votes, not like evidence', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      // Sub-threshold detection must not preserve or re-confirm the letter.
      expect(s.update('A', 0.30), isNull);
      // A different sub-threshold token must not vote either.
      expect(s.update('C', 0.10), isNull);
    });

    test('A -> B -> A works repeatedly in both directions', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      final toB = feed(s, List.filled(6, (('B'), 0.85)));
      expect(toB.last, 'B');
      final backToA = feed(s, List.filled(6, (('A'), 0.90)));
      expect(backToA.last, 'A');
    });

    test('unstable transitional poses never emit phantom letters', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      final results = feed(
        s,
        const [('B', 0.9), ('C', 0.9), ('B', 0.9), ('D', 0.9), ('C', 0.9)],
      );
      expect(results, everyElement(isNull));
    });

    test('reset clears history so nothing survives a pipeline restart', () {
      final s = SignDetectionStabilizer();
      feed(s, List.filled(9, (('A'), 0.90)));
      s.reset();
      expect(s.update(null, 0), isNull);
      final results = feed(s, List.filled(4, (('A'), 0.90)));
      expect(results, everyElement(isNull));
      expect(s.update('A', 0.90), 'A');
    });
  });
}
