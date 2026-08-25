/// Single authoritative definition of the Arabic sign vocabulary shared by
/// the Sign→Text classifier and the Text→Sign player.
///
/// The [_tokens] list order IS the TFLite classifier output order and must
/// never be reordered without re-exporting the model. Asset file names equal
/// the English label plus ".jpg".
library;

/// One supported sign: its classifier label / asset name and the Arabic
/// token users see and type.
class ArabicSignToken {
  const ArabicSignToken(this.label, this.arabic);

  /// English class label; also the asset file stem (e.g. "Ain.jpg").
  final String label;

  /// Arabic token emitted by recognition and matched during tokenization.
  /// Mostly a single character, but compound signs exist ('لا', 'ال').
  final String arabic;
}

abstract final class ArabicSignAlphabet {
  /// Order = classifier class index. Do not sort or edit casually.
  static const List<ArabicSignToken> _tokens = [
    ArabicSignToken('Ain', 'ع'),
    ArabicSignToken('Al', 'ال'),
    ArabicSignToken('Alef', 'ا'),
    ArabicSignToken('Beh', 'ب'),
    ArabicSignToken('Dad', 'ض'),
    ArabicSignToken('Dal', 'د'),
    ArabicSignToken('Feh', 'ف'),
    ArabicSignToken('Ghain', 'غ'),
    ArabicSignToken('Hah', 'ح'),
    ArabicSignToken('Heh', 'ه'),
    ArabicSignToken('Jeem', 'ج'),
    ArabicSignToken('Kaf', 'ك'),
    ArabicSignToken('Khah', 'خ'),
    ArabicSignToken('Laa', 'لا'),
    ArabicSignToken('Lam', 'ل'),
    ArabicSignToken('Meem', 'م'),
    ArabicSignToken('Noon', 'ن'),
    ArabicSignToken('Qaf', 'ق'),
    ArabicSignToken('Reh', 'ر'),
    ArabicSignToken('Sad', 'ص'),
    ArabicSignToken('Seen', 'س'),
    ArabicSignToken('Sheen', 'ش'),
    ArabicSignToken('Tah', 'ط'),
    ArabicSignToken('Teh', 'ت'),
    ArabicSignToken('Teh_Marbuta', 'ة'),
    ArabicSignToken('Theh', 'ث'),
    ArabicSignToken('Waw', 'و'),
    ArabicSignToken('Yeh', 'ي'),
    ArabicSignToken('Zah', 'ظ'),
    ArabicSignToken('Zain', 'ز'),
    ArabicSignToken('Thal', 'ذ'),
  ];

  static final Map<String, ArabicSignToken> _byArabic = {
    for (final t in _tokens) t.arabic: t,
  };

  /// Number of classifier output classes.
  static int get classCount => _tokens.length;

  /// Token at a classifier output index; index must be within range.
  static ArabicSignToken tokenForClass(int index) => _tokens[index];

  static ArabicSignToken? tokenForArabic(String arabicToken) =>
      _byArabic[arabicToken];

  /// Asset file name for an Arabic token, or null when unsupported.
  static String? assetFileFor(String arabicToken) =>
      _byArabic[arabicToken]?.label;

  /// Longest-match tokenizer over the supported vocabulary.
  ///
  /// Compound tokens win over their single-character parts, so "لا" becomes
  /// ["لا"] and "ال" becomes ["ال"] instead of two separate letters.
  /// Whitespace is dropped. Unknown characters are kept so callers can
  /// present them as unsupported.
  static List<String> tokenize(String input) {
    final characters = input.split('');
    final result = <String>[];
    var i = 0;
    while (i < characters.length) {
      final character = characters[i];
      if (character.trim().isEmpty) {
        i++;
        continue;
      }
      if (i + 1 < characters.length) {
        final pair = character + characters[i + 1];
        if (_byArabic.containsKey(pair)) {
          result.add(pair);
          i += 2;
          continue;
        }
      }
      result.add(character);
      i++;
    }
    return result;
  }
}
