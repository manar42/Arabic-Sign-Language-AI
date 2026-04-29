import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';
import '../services/classifier_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SignToTextScreen extends StatefulWidget {
  const SignToTextScreen({super.key});
  @override
  State<SignToTextScreen> createState() => _SignToTextScreenState();
}

class _SignToTextScreenState extends State<SignToTextScreen> {
  CameraController? _cameraController;
  HandLandmarkerPlugin? _handLandmarker;
  String _result = 'وجّه الكاميرا على يدك';
  String _sentence = '';
  final _classifier = ClassifierService();
  bool _isProcessing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupEverything();
  }

  Future<void> _setupEverything() async {
    // اطلب إذن الكاميرا أولاً
    final status = await Permission.camera.request();
    if (status.isDenied) return;

    await _classifier.loadModel();

    // الـ API الصح بتاع الـ package
    _handLandmarker = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.5,
      delegate: HandLandmarkerDelegate.cpu,
    );

    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // أضمن للتوافق
    );

    await _cameraController!.initialize();
    await _cameraController!.startImageStream(_processFrame);

    if (mounted) setState(() => _isInitialized = true);
  }

  // متغير لحفظ الحرف المكتشف حالياً فقط
  String _currentDetectedSign = '';

  void _processFrame(CameraImage frame) async {
    if (_isProcessing || !_isInitialized || _handLandmarker == null) return;
    _isProcessing = true;

    try {
      final hands = _handLandmarker!.detect(
        frame,
        _cameraController!.description.sensorOrientation,
      );

      if (hands.isNotEmpty) {
        final landmarks = hands.first.landmarks;
        List<double> input = [];
        for (var point in landmarks) {
          input.add(point.x);
          input.add(point.y);
          input.add(point.z);
        }
        final sign = _classifier.classify(input);
        if (mounted) {
          setState(() {
            _currentDetectedSign = sign;
            _result = sign;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentDetectedSign = '';
            _result = 'لم يتم اكتشاف يد';
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _handLandmarker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إشارة → نص')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _isInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: 32, // تم تقليل حجم الخط لتجنب الـ overflow
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        'الجملة: $_sentence',
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentDetectedSign.isEmpty
                              ? null
                              : () => setState(() => _sentence += _currentDetectedSign),
                          icon: const Icon(Icons.add),
                          label: const Text('أضف حرف'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _sentence = ''),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('مسح'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}