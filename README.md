# إشارة — Ishara

<p align="center">
  <strong>Arabic Sign Language → Text & Text → Sign</strong>
</p>

<p align="center">
  تطبيق Flutter لترجمة لغة الإشارة العربية إلى نص عربي والعكس، باستخدام معالجة محلية بالكامل على الجهاز ودون الحاجة إلى اتصال بالإنترنت.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-UI-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/MediaPipe-Hand%20Landmarker-4285F4?logo=google&logoColor=white" alt="MediaPipe">
  <img src="https://img.shields.io/badge/TensorFlow%20Lite-On--Device%20ML-FF6F00?logo=tensorflow&logoColor=white" alt="TensorFlow Lite">
  <img src="https://img.shields.io/badge/Android-Recognition-3DDC84?logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/Offline-On--Device-0F766E" alt="Offline">
</p>

---


## 🌟 Overview

**إشارة — Ishara** is a Flutter application designed to facilitate communication using Arabic Sign Language.

The application provides two complementary translation paths:

- **Sign → Text** — uses the device camera to recognize supported Arabic hand signs and convert them into Arabic characters.
- **Text → Sign** — converts Arabic text into a visual sequence of corresponding sign assets.

The recognition pipeline is designed to run **entirely on-device**, without sending camera frames or recognition data to a remote AI service.

The current implementation focuses on **Arabic alphabet-level sign recognition**, with **31 supported sign classes**, including the compound classes **ال** and **لا**.

---

# ✨ Key Features

### 🤟 Sign → Text

- Real-time camera-based hand-sign recognition.
- MediaPipe Hand Landmarker for hand landmark extraction.
- TensorFlow Lite for on-device classification.
- Arabic character recognition.
- Temporal stabilization to reduce unstable frame predictions.
- Manual sentence construction.
- No automatic word prediction or cloud-based interpretation.

### 📝 Text → Sign

- Arabic text tokenization.
- Deterministic mapping between supported tokens and sign assets.
- Sequential visual presentation of signs.
- Native support for compound classes such as `ال` and `لا`.

### 📱 Application

- Flutter-based mobile UI.
- Material 3 design foundation.
- Light / Dark theme support.
- Arabic and English localization.
- Full RTL support.
- Offline-first recognition architecture.
- Android-focused recognition pipeline.

---

# 🧠 On-Device Recognition Architecture

Instead of sending camera frames to a remote computer-vision service, the recognition pipeline executes locally on the Android device.

```text
Camera
   │
   ▼
MediaPipe Hand Landmarker
   │
   ▼
21 Hand Landmarks
   │
   ▼
TensorFlow Lite
   │
   ▼
Sign Classification
   │
   ▼
Temporal Stabilizer
   │
   ▼
Arabic Character
   │
   ▼
Sentence

Why this architecture?

The application uses MediaPipe to convert raw camera input into structured hand-landmark information before classification.

The TensorFlow Lite model then operates on this representation instead of depending on a remote computer-vision service.

This architecture provides:

Lower inference complexity.
Smaller model input.
Fast mobile inference.
Offline execution.
Lower latency.
Better privacy.
No server-side recognition infrastructure.
No dependency on external AI APIs.
🔄 Text → Sign Pipeline

The reverse translation path uses a deterministic tokenizer and sign-asset resolver.

Arabic Text
     │
     ▼
Tokenizer
     │
     ├── Arabic Character
     ├── "ال"
     └── "لا"
     │
     ▼
Supported Sign Token
     │
     ▼
Sign Asset Resolver
     │
     ▼
Sign Image Sequence
     │
     ▼
Visual Presentation

Compound units such as ال and لا are treated as independent supported classes rather than being reconstructed dynamically at runtime.

This keeps the mapping deterministic and predictable.

🎯 Recognition Flow

The application separates machine-learning inference from application-level decisions.

Camera Frame
     │
     ▼
Hand Detection
     │
     ▼
Landmark Extraction
     │
     ▼
Model Prediction
     │
     ▼
Temporal Stabilization
     │
     ├── Unstable → Ignore
     │
     └── Stable → Accept
                    │
                    ▼
              Arabic Character
                    │
                    ▼
                 Sentence

This separation allows the recognition engine and the UI to evolve independently.

🧩 Recognition Stabilization

Raw model predictions can fluctuate between consecutive camera frames.

For example:

Frame 1 → ب
Frame 2 → ب
Frame 3 → ت
Frame 4 → ب
Frame 5 → ب

Directly consuming every prediction could produce unstable text.

Ishara therefore uses a dedicated temporal stabilization layer that evaluates consecutive predictions before accepting a character.

Conceptually:

Raw Predictions
       │
       ▼
Temporal Stabilizer
       │
       ├── Stable ──────► Accept
       │
       └── Unstable ────► Ignore

This keeps ML inference separate from recognition decisions, making the pipeline easier to test, maintain, and optimize.

🔤 Supported Sign Classes

The current model supports 31 sign classes.

Arabic	Class	Arabic	Class	Arabic	Class
ع	Ain	ض	Dad	ط	Tah
ا	Alef	د	Dal	ت	Teh
ب	Beh	ف	Feh	ة	Teh_Marbuta
غ	Ghain	ج	Jeem	ث	Theh
ح	Hah	خ	Khah	و	Waw
ه	Heh	م	Meem	ي	Yeh
ك	Kaf	ن	Noon	ظ	Zah
ل	Lam	ر	Reh	ز	Zain
س	Seen	ذ	Thal	ش	Sheen
ص	Sad	ال	Al	لا	Laa

Note: ال and لا are independent classes in the current model and asset set.

🏗️ Architecture

The project separates recognition logic, application services, UI, localization, and reusable design components.

lib/
│
├── core/
│   ├── Arabic sign alphabet contracts
│   └── Recognition stabilization
│
├── design/
│   ├── Theme
│   ├── Design tokens
│   └── Shared UI components
│
├── l10n/
│   ├── Arabic localization
│   └── English localization
│
├── screens/
│   ├── Sign → Text
│   ├── Text → Sign
│   └── Main application screens
│
└── services/
    ├── Camera
    ├── MediaPipe
    ├── TensorFlow Lite
    └── Sign recognition

The recognition engine is intentionally separated from the presentation layer so that the inference pipeline can evolve independently from the UI.

🛠️ Technology Stack
Technology	Purpose
Flutter	Cross-platform application UI
Dart	Application programming language
MediaPipe Hand Landmarker	Hand landmark extraction
TensorFlow Lite	On-device sign classification
Camera	Real-time camera input
Material 3	Modern UI foundation
Flutter Localization	Arabic / English localization
Dart Unit Tests	Core behavior verification
🔐 Privacy & Offline Architecture

Privacy and offline execution are core design requirements.

The recognition pipeline does not require:

Backend servers.
Cloud inference.
External AI APIs.
API keys.
Remote image processing.
Internet connectivity.

The recognition flow is entirely local:

Camera
  │
  ▼
Android Device
  │
  ├── MediaPipe
  │
  ├── TensorFlow Lite
  │
  └── Recognition Result

Camera frames and hand landmarks are processed locally.

No recognition request needs to leave the device.

This makes the application suitable for environments where:

Internet connectivity is unavailable.
Privacy is important.
Low latency is required.
Cloud inference is undesirable.
⚡ Performance-Oriented Design

The recognition pipeline is designed around mobile-device constraints.

Key considerations include:

Lightweight landmark-based model input.
On-device TensorFlow Lite inference.
Temporal stabilization instead of blindly accepting every frame.
Separation between frame processing and sentence construction.
Deterministic text-to-sign mapping.
Reusable sign assets.
Minimal runtime dependencies for the recognition path.

The goal is not simply to recognize a gesture, but to build a recognition pipeline that can continuously operate on a mobile device.

🧪 Testing

The project includes automated tests for important recognition contracts.

Run static analysis
flutter analyze
Run focused recognition tests
flutter test test/arabic_sign_alphabet_test.dart test/sign_detection_stabilizer_test.dart
Arabic Sign Alphabet Tests

The alphabet tests verify:

Number of supported classes.
Uniqueness of sign tokens.
Supported compound signs.
Text tokenization behavior.
Recognition Stabilizer Tests

The stabilizer tests cover:

Acceptance of stable predictions.
Rejection of unstable frames.
Transitions between different signs.
State reset when the hand is lost.
📂 Project Structure
.
├── android/
│
├── assets/
│   ├── images/
│   │   ├── 1.jpg
│   │   ├── 2.jpg
│   │   ├── 3.jpg
│   │   └── 4.jpg
│   │
│   ├── models/
│   │   ├── sign_classifier.tflite
│   │   └── hand_landmarker.task
│   │
│   └── signs/
│       └── Arabic sign assets
│
├── lib/
│   ├── core/
│   ├── design/
│   ├── l10n/
│   ├── screens/
│   └── services/
│
├── test/
│   ├── arabic_sign_alphabet_test.dart
│   └── sign_detection_stabilizer_test.dart
│
├── pubspec.yaml
└── README.md
🚀 Getting Started
Requirements
Flutter SDK.
Dart SDK compatible with the project.
Android device.
Camera permission.

The current MediaPipe recognition implementation targets Android.

Installation

Clone the repository:

git clone <YOUR_REPOSITORY_URL>
cd <YOUR_PROJECT_DIRECTORY>

Install dependencies:

flutter pub get

Run the application:

flutter run

Grant camera permission when requested.

📱 Platform Support
Platform	UI	Sign Recognition
Android	✅	✅
iOS	⚠️	Not currently supported
Web	⚠️	Not currently supported
Desktop	⚠️	Not currently supported

The current recognition implementation is specifically designed around the Android camera + MediaPipe pipeline.

🎯 Current Scope

The current version focuses on Arabic alphabet-level sign recognition rather than full natural-language sign-language translation.

Supported
Arabic alphabet signs.
Compound classes ال and لا.
Character-by-character sentence construction.
Text-to-sign visual sequences.
Offline on-device recognition.
Not currently supported
Full-word sign recognition.
Full sentence sign-language understanding.
Numbers.
Continuous natural-language interpretation.
Sign-language grammar reconstruction.
⚠️ Current Limitations

Recognition quality depends on the trained model and input conditions.

Potential sources of confusion include:

Visually similar hand gestures.
Camera angle.
Lighting conditions.
Hand orientation.
Occlusion.
Distance from the camera.
Motion blur.

The current model supports 31 classes and is therefore not intended to represent the complete vocabulary or grammar of Arabic Sign Language.

🗺️ Roadmap
Recognition
Improve classification accuracy.
Reduce confusion between visually similar signs.
Improve robustness across different lighting conditions.
Expand the sign dataset.
Add more Arabic sign classes.
Explore continuous sign recognition.
User Experience
Improve sentence-building workflow.
Add richer recognition feedback.
Improve camera guidance.
Improve accessibility-focused interactions.
Improve sign-sequence playback.
Platform
Explore iOS recognition support.
Evaluate additional on-device inference options.
Improve cross-platform abstraction around the recognition engine.
💡 Engineering Highlights

This project demonstrates practical experience across several areas of modern mobile and on-device AI application development:

Flutter application development
Dart
Computer Vision
MediaPipe
TensorFlow Lite
On-device Machine Learning
Real-time camera processing
Arabic / RTL localization
Material 3 Design System
Offline-first architecture
Temporal signal stabilization
Asset-driven visual rendering
Unit testing
Mobile performance considerations

The project combines traditional Flutter application engineering with an on-device machine-learning pipeline instead of relying on a remote AI service.

🔬 Technical Design Philosophy

The application follows a simple principle:

Keep recognition local, deterministic, testable, and independent from the UI.

The camera layer is responsible for acquiring frames.

MediaPipe is responsible for extracting hand landmarks.

TensorFlow Lite is responsible for classification.

The stabilizer is responsible for deciding when a prediction is reliable enough to accept.

The application layer is responsible for turning accepted predictions into user-visible text.

This separation makes each component easier to reason about, test, optimize, and replace independently.

📸 Repository Screenshots

Application screenshots are stored directly inside the repository:

assets/images/1.jpg
assets/images/2.jpg
assets/images/3.jpg
assets/images/4.jpg

They are displayed near the beginning of this README to provide an immediate visual overview of the application.

🤝 Contributing

This is currently a personal / educational project.

Suggestions, bug reports, and improvements are welcome through GitHub Issues and Pull Requests.

