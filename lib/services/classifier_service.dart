import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../core/arabic_sign_alphabet.dart';

/// Raw single-frame classification outcome.
class FrameClassification {
  const FrameClassification(this.token, this.confidence);

  /// Arabic token from the unified vocabulary.
  final String token;

  /// The model's own maximum output value for the winning class. Not
  /// synthesized; frames below the stabilizer threshold simply do not vote.
  final double confidence;
}

/// Thin wrapper around the bundled TFLite sign classifier.
///
/// Class indexes come from [ArabicSignAlphabet]; this class owns no
/// duplicated label data.
class ClassifierService {
  Interpreter? _interpreter;

  bool get isReady => _interpreter != null;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/sign_classifier.tflite',
    );
  }

  /// Best-effort single-frame inference. Returns null when the model is not
  /// loaded or inference fails, so callers can treat it as "no result".
  ///
  /// When [debugOutputs] is supplied, the raw class-output vector is copied
  /// into it for diagnostics; production behavior is unchanged otherwise.
  FrameClassification? classify(
    List<double> landmarks, {
    List<double>? debugOutputs,
  }) {
    final interpreter = _interpreter;
    if (interpreter == null) return null;

    final output = List.filled(
      ArabicSignAlphabet.classCount,
      0.0,
    ).reshape([1, ArabicSignAlphabet.classCount]);

    try {
      interpreter.run([landmarks], output);
    } catch (e) {
      debugPrint('Classifier inference failed: $e');
      return null;
    }

    final flat = <double>[
      for (var i = 0; i < ArabicSignAlphabet.classCount; i++)
        (output[0][i] as num).toDouble(),
    ];
    debugOutputs?.setAll(0, flat);

    var maxIndex = 0;
    for (var i = 1; i < flat.length; i++) {
      if (flat[i] > flat[maxIndex]) maxIndex = i;
    }

    return FrameClassification(
      ArabicSignAlphabet.tokenForClass(maxIndex).arabic,
      flat[maxIndex],
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
