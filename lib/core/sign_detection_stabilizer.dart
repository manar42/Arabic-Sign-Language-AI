import 'dart:collection';

/// Bounded rolling-window majority vote over per-frame classifications.
///
/// Design rationale for the defaults:
/// - [windowSize] 9: at the throttled processing rate (~15 fps) the window
///   spans roughly 0.6 s — long enough that a single noisy frame can never
///   flip the accepted letter (flipping requires a strict majority of
///   agreeing frames), short enough that switching signs still feels
///   immediate.
/// - A frame only votes when its confidence reaches [minConfidence]; frames
///   below it (or with no hand) enter the window as non-votes, so sustained
///   uncertainty naturally decays an existing stable letter instead of
///   freezing it.
/// - The latest window entry must itself agree with the winner, which keeps
///   reactions to genuine sign changes fast while isolated spikes stay inert.
class SignDetectionStabilizer {
  SignDetectionStabilizer({
    this.windowSize = 9,
    this.minConfidence = 0.60,
  })  : assert(windowSize >= 3, 'window must be large enough to vote'),
        assert(minConfidence > 0.0 && minConfidence < 1.0);

  final int windowSize;
  final double minConfidence;

  // NOTE: the element type MUST be the nullable record. A non-nullable type
  // argument would make addLast(null) throw "Null is not a subtype of
  // (String, double)" on every no-hand / low-confidence frame, which both
  // spams errors and freezes the window on stale entries (stuck letter).
  final ListQueue<(String token, double confidence)?> _window =
      ListQueue<(String token, double confidence)?>();

  /// Minimum agreeing frames required to accept a letter.
  int get _minVotes => (windowSize * 0.55).ceil();

  /// Feed one frame's raw best guess; returns the stabilized Arabic token,
  /// or null when no letter is currently accepted.
  String? update(String? token, double confidence) {
    if (token != null && confidence >= minConfidence) {
      _window.addLast((token, confidence));
    } else {
      _window.addLast(null);
    }
    while (_window.length > windowSize) {
      _window.removeFirst();
    }

    final last = _window.last;
    if (last == null) return null;

    var votes = 0;
    for (final entry in _window) {
      if (entry != null && entry.$1 == last.$1) votes++;
    }
    return votes >= _minVotes ? last.$1 : null;
  }

  /// Clears history; call when detection restarts (retry, teardown).
  void reset() => _window.clear();
}
