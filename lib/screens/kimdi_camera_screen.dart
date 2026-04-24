import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class KimdiCameraScreen extends StatefulWidget {
  const KimdiCameraScreen({super.key});

  @override
  State<KimdiCameraScreen> createState() => _KimdiCameraScreenState();
}

class _KimdiCameraScreenState extends State<KimdiCameraScreen> {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  String resultText = "Kamera açılıyor...";
  bool loading = false;

  final FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
      enableContours: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), openCamera);
  }

  Future<void> openCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      setState(() => resultText = "Fotoğraf çekilmedi.");
      return;
    }

    setState(() {
      selectedImage = File(image.path);
      loading = true;
      resultText = "Yüz analiz ediliyor...";
    });

    await recognizePerson(File(image.path));
  }

  Future<File> assetToFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();

    final safeName = fileName.replaceAll(" ", "_");
    final file = File("${tempDir.path}/$safeName");

    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  Future<List<String>> getImageAssets() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');

    final regex = RegExp(
      r'assets/images/[^"]+\.(jpg|jpeg|png|JPG|JPEG|PNG)',
    );

    final matches = regex.allMatches(manifestJson);

    return matches.map((e) => e.group(0)!).toSet().toList();
  }

  String nameFromAssetPath(String path) {
    final fileName = path.split('/').last;
    final nameWithoutExt = fileName.split('.').first;
    return nameWithoutExt.replaceAll("_", " ");
  }

  Future<List<Face>> detectFaces(File file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    return await detector.processImage(inputImage);
  }

  double distance(Point<int> a, Point<int> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  double? faceSignature(Face face) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
    final nose = face.landmarks[FaceLandmarkType.noseBase]?.position;
    final mouthLeft = face.landmarks[FaceLandmarkType.leftMouth]?.position;
    final mouthRight = face.landmarks[FaceLandmarkType.rightMouth]?.position;

    if (leftEye == null ||
        rightEye == null ||
        nose == null ||
        mouthLeft == null ||
        mouthRight == null) {
      return null;
    }

    final eyeDistance = distance(leftEye, rightEye);
    final mouthDistance = distance(mouthLeft, mouthRight);
    final noseToEye = distance(nose, leftEye) + distance(nose, rightEye);

    if (eyeDistance == 0) return null;

    return (mouthDistance / eyeDistance) + (noseToEye / eyeDistance);
  }

  Future<void> recognizePerson(File cameraFile) async {
    try {
      final cameraFaces = await detectFaces(cameraFile);

      if (cameraFaces.isEmpty) {
        setState(() {
          resultText = "Yüz bulunamadı.";
          loading = false;
        });
        return;
      }

      final cameraSig = faceSignature(cameraFaces.first);

      if (cameraSig == null) {
        setState(() {
          resultText = "Yüz net okunamadı.";
          loading = false;
        });
        return;
      }

      final imageAssets = await getImageAssets();

      if (imageAssets.isEmpty) {
        setState(() {
          resultText = "Kayıtlı kişi fotoğrafı yok.";
          loading = false;
        });
        return;
      }

      double bestScore = 999;
      String bestName = "Bilinmiyor";

      for (final assetPath in imageAssets) {
        final fileName = assetPath.split('/').last;
        final assetFile = await assetToFile(assetPath, fileName);

        final faces = await detectFaces(assetFile);
        if (faces.isEmpty) continue;

        final sig = faceSignature(faces.first);
        if (sig == null) continue;

        final diff = (cameraSig - sig).abs();

        if (diff < bestScore) {
          bestScore = diff;
          bestName = nameFromAssetPath(assetPath);
        }
      }

      setState(() {
        if (bestScore < 0.18) {
          resultText = "Bu kişi: $bestName";
        } else {
          resultText = "Kişi bulunamadı.";
        }

        loading = false;
      });
    } catch (e) {
      setState(() {
        resultText = "Hata: $e";
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E8EE),
      appBar: AppBar(
        title: const Text(
          "Kimdi?",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8E8EE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 420,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: selectedImage == null
                  ? const Center(
                      child: Text(
                        "Kamera açılıyor...",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: loading ? null : openCamera,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text(
                  "Tekrar Tara",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D4F8F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}