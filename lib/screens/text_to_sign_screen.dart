import 'package:flutter/material.dart';

class TextToSignScreen extends StatefulWidget {
  const TextToSignScreen({super.key});
  @override
  State<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends State<TextToSignScreen> {
  final _controller = TextEditingController();
  int _currentIndex = 0;
  List<String> _letters = [];
  bool _playing = false;

  // تحويل الحرف العربي لاسم الصورة
  final Map<String, String> arabicToFileName = {
    'ع': 'Ain', 'ال': 'Al', 'ا': 'Alef', 'ب': 'Beh',
    'ض': 'Dad', 'د': 'Dal', 'ف': 'Feh', 'غ': 'Ghain',
    'ح': 'Hah', 'ه': 'Heh', 'ج': 'Jeem', 'ك': 'Kaf',
    'خ': 'Khah', 'لا': 'Laa', 'ل': 'Lam', 'م': 'Meem',
    'ن': 'Noon', 'ق': 'Qaf', 'ر': 'Reh', 'ص': 'Sad',
    'س': 'Seen', 'ش': 'Sheen', 'ط': 'Tah', 'ت': 'Teh',
    'ة': 'Teh_Marbuta', 'ث': 'Theh', 'و': 'Waw', 'ي': 'Yeh',
    'ظ': 'Zah', 'ز': 'Zain', 'ذ': 'Thal',
  };

  void _play() async {
    setState(() {
      _letters = _controller.text
          .split('')
          .where((c) => c.trim().isNotEmpty)
          .toList();
      _currentIndex = 0;
      _playing = true;
    });

    for (int i = 0; i < _letters.length; i++) {
      if (!_playing) break;
      setState(() => _currentIndex = i);
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    final letter = _letters.isNotEmpty ? _letters[_currentIndex] : '';
    final fileName = arabicToFileName[letter];

    return Scaffold(
      appBar: AppBar(title: const Text('نص → إشارة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'اكتب كلمة...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: Icon(Icons.text_fields, color: Theme.of(context).primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _playing ? null : _play,
              icon: const Icon(Icons.play_arrow, size: 24),
              label: const Text('عرض الإشارة', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (letter.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // عرض الصورة
                    if (fileName != null)
                      Image.asset(
                        'assets/signs/$fileName.jpg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Column(
                          children: [
                            const Icon(Icons.image_not_supported,
                                size: 80, color: Colors.grey),
                            Text('صورة $fileName غير موجودة',
                                style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    else
                      const Icon(Icons.help_outline,
                          size: 80, color: Colors.grey),

                    const SizedBox(height: 8),

                    // الحرف العربي
                    Text(
                      letter,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'الحرف ${_currentIndex + 1} من ${_letters.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (_letters.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _letters.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _currentIndex
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}