import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;
  
  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    
    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    
    await controller!.initialize();
  }
  
  void dispose() {
    controller?.dispose();
  }
}
