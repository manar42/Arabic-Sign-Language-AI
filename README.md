# Sign Language Translator App 🤟

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/TensorFlow_Lite-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white" alt="TensorFlow Lite" />
  <img src="https://img.shields.io/badge/MediaPipe-00B2A9?style=for-the-badge&logo=mediapipe&logoColor=white" alt="MediaPipe" />
</div>

<br/>

A comprehensive Flutter application designed to bridge the communication gap by providing real-time two-way translation between Arabic Sign Language (ArSL) and Arabic text. It leverages on-device Machine Learning for fast, offline, and reliable gesture recognition.

---

## ✨ Features

### 1. Sign-to-Text Translation
- **Real-time Recognition**: Utilizes the device's camera to detect hand gestures in real-time.
- **AI-Powered**: Powered by **MediaPipe** for precise hand landmark extraction and a custom **TensorFlow Lite (TFLite)** neural network to classify these landmarks into Arabic letters.
- **Word & Sentence Building**: Allows users to seamlessly concatenate detected letters into words and full sentences, with options to delete or clear the workspace.

### 2. Text-to-Sign Translation
- **Visual Playback**: Converts Arabic text input into a clear, animated sequence of sign language images.
- **Educational Value**: Extremely helpful for those who want to learn Arabic sign language or communicate back seamlessly.

### 3. Premium UI/UX Design
- **Modern Aesthetic**: Features a highly polished, responsive interface using Indigo & Emerald gradients.
- **Adaptive Layout**: Smartly handles varying screen sizes, ensuring UI elements scale gracefully without overflow warnings (even in split-camera views).
- **Smooth Animations**: Incorporates soft shadows, rounded corners, and smooth transitions for a premium native feel.

---

## 🛠️ Tech Stack & Architecture

- **Frontend Framework**: [Flutter](https://flutter.dev/) & Dart.
- **Computer Vision**: [MediaPipe](https://mediapipe.dev/) via the `hand_landmarker` plugin for extracting 3D hand skeletal coordinates.
- **Machine Learning**: Custom Classification Model via `tflite_flutter` optimized for mobile devices.
- **Hardware Integrations**: `camera` package for low-latency live camera streaming and `permission_handler` for secure access management.

---

## 🚀 Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- Android Studio / Xcode for emulators or physical device deployment

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/sign_language_app.git
   cd sign_language_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
   > **Note:** For the best experience and performance (especially for real-time camera tracking and ML inference), testing on a physical device is highly recommended over a simulator.

---

## 📂 Project Structure

```text
lib/
 ├── main.dart                  # Application entry point & Theme configuration
 ├── screens/                   # UI Presentation Layer
 │    ├── home_screen.dart        # Main navigation and mode selection
 │    ├── sign_to_text_screen.dart # Real-time camera & gesture detection UI
 │    └── text_to_sign_screen.dart # Text input & image sequence playback UI
 └── services/                  # Business Logic & AI Integrations
      ├── classifier_service.dart # TFLite model loading & inference engine
      └── mediapipe_service.dart  # Hand tracking pipeline controllers
```

---

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

Distributed under the MIT License. See the `LICENSE` file for more information.
