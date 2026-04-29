import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  Interpreter? _interpreter;

  final List<String> labels = [
    'Ain', 'Al', 'Alef', 'Beh', 'Dad', 'Dal',
    'Feh', 'Ghain', 'Hah', 'Heh', 'Jeem', 'Kaf',
    'Khah', 'Laa', 'Lam', 'Meem', 'Noon', 'Qaf',
    'Reh', 'Sad', 'Seen', 'Sheen', 'Tah', 'Teh',
    'Teh_Marbuta', 'Theh', 'Waw', 'Yeh', 'Zah',
    'Zain', 'Thal',
  ];

  final Map<String, String> labelToArabic = {
    'Ain': 'ع', 'Al': 'ال', 'Alef': 'ا',
    'Beh': 'ب', 'Dad': 'ض', 'Dal': 'د',
    'Feh': 'ف', 'Ghain': 'غ', 'Hah': 'ح',
    'Heh': 'ه', 'Jeem': 'ج', 'Kaf': 'ك',
    'Khah': 'خ', 'Laa': 'لا', 'Lam': 'ل',
    'Meem': 'م', 'Noon': 'ن', 'Qaf': 'ق',
    'Reh': 'ر', 'Sad': 'ص', 'Seen': 'س',
    'Sheen': 'ش', 'Tah': 'ط', 'Teh': 'ت',
    'Teh_Marbuta': 'ة', 'Theh': 'ث', 'Waw': 'و',
    'Yeh': 'ي', 'Zah': 'ظ', 'Zain': 'ز',
    'Thal': 'ذ',
  };

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/sign_classifier.tflite',
    );
  }

  String classify(List<double> landmarks) {
    var input = [landmarks];
    var output = List.filled(1 * labels.length, 0.0)
        .reshape([1, labels.length]);

    _interpreter!.run(input, output);

    int maxIdx = 0;
    for (int i = 1; i < output[0].length; i++) {
      if (output[0][i] > output[0][maxIdx]) maxIdx = i;
    }

    final englishLabel = labels[maxIdx];
    // بيرجع الحرف العربي بدل الإنجليزي
    return labelToArabic[englishLabel] ?? englishLabel;
  }
}