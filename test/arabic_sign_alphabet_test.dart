import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/core/arabic_sign_alphabet.dart';

void main() {
  group('ArabicSignAlphabet', () {
    test('class count matches the exported TFLite model output', () {
      // The bundled sign_classifier.tflite was trained with 31 classes in
      // this exact order; changing either side silently breaks recognition.
      expect(ArabicSignAlphabet.classCount, 31);
    });

    test('labels and Arabic tokens are unique (compound-safe)', () {
      final labels = <String>{};
      final arabic = <String>{};
      for (var i = 0; i < ArabicSignAlphabet.classCount; i++) {
        final token = ArabicSignAlphabet.tokenForClass(i);
        expect(labels.add(token.label), isTrue,
            reason: 'duplicate label ${token.label}');
        expect(arabic.add(token.arabic), isTrue,
            reason: 'duplicate arabic ${token.arabic}');
      }
    });

    test('index lookup and Arabic lookup agree for every class', () {
      for (var i = 0; i < ArabicSignAlphabet.classCount; i++) {
        final byIndex = ArabicSignAlphabet.tokenForClass(i);
        final byArabic = ArabicSignAlphabet.tokenForArabic(byIndex.arabic);
        expect(byArabic?.label, byIndex.label);
      }
    });

    test('asset stems cover every token and reject unknown input', () {
      expect(ArabicSignAlphabet.assetFileFor('ع'), 'Ain');
      expect(ArabicSignAlphabet.assetFileFor('لا'), 'Laa');
      expect(ArabicSignAlphabet.assetFileFor('ال'), 'Al');
      expect(ArabicSignAlphabet.assetFileFor('ة'), 'Teh_Marbuta');
      expect(ArabicSignAlphabet.assetFileFor('ذ'), 'Thal');
      expect(ArabicSignAlphabet.assetFileFor('zz'), isNull);
    });

    group('tokenize', () {
      test('splits plain letters', () {
        expect(ArabicSignAlphabet.tokenize('نور'), ['ن', 'و', 'ر']);
      });

      test('keeps compound signs atomic via longest match', () {
        expect(ArabicSignAlphabet.tokenize('لا'), ['لا']);
        expect(ArabicSignAlphabet.tokenize('ال'), ['ال']);
        expect(ArabicSignAlphabet.tokenize('لال'), ['لا', 'ل']);
        expect(
          ArabicSignAlphabet.tokenize('الا'),
          ['ال', 'ا'],
        );
      });

      test('drops whitespace between tokens', () {
        expect(ArabicSignAlphabet.tokenize('لا ا'), ['لا', 'ا']);
        expect(ArabicSignAlphabet.tokenize(' ن و ر '), ['ن', 'و', 'ر']);
      });

      test('keeps unsupported characters visible to the caller', () {
        expect(ArabicSignAlphabet.tokenize('ab1'), ['a', 'b', '1']);
      });

      test('empty input produces no tokens', () {
        expect(ArabicSignAlphabet.tokenize(''), isEmpty);
      });
    });
  });
}
