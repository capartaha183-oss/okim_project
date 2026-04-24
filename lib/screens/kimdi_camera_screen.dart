import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_colors.dart';

class KimdiCameraScreen extends StatefulWidget {
  const KimdiCameraScreen({super.key});

  @override
  State<KimdiCameraScreen> createState() => _KimdiCameraScreenState();
}

class _KimdiCameraScreenState extends State<KimdiCameraScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  bool loading = false;

  String resultTitle = "Tarama hazır";
  String resultSubtitle = "Kamera ile fotoğraf çekerek kayıtlı kişilerle karşılaştır.";
  IconData resultIcon = Icons.camera_alt_rounded;
  Color resultColor = AppColors.primary;

  late AnimationController scanController;

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
    scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  Future<void> openCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
      loading = true;
      resultTitle = "Analiz ediliyor";
      resultSubtitle = "Yüz verileri kayıtlı kişilerle karşılaştırılıyor.";
      resultIcon = Icons.manage_search_rounded;
      resultColor = AppColors.primary;
    });

    await recognizePerson(File(image.path));
  }

  Future<List<Face>> detectFaces(File file) async {
    final inputImage = InputImage.fromFilePath(file.path);
    return detector.processImage(inputImage);
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
      final prefs = await SharedPreferences.getInstance();
      final savedPeople = prefs.getStringList("people") ?? [];

      if (savedPeople.isEmpty) {
        setState(() {
          loading = false;
          resultTitle = "Kayıtlı kişi yok";
          resultSubtitle = "Önce Kayıtlı Kişiler ekranından kişi ekle.";
          resultIcon = Icons.person_add_alt_1_rounded;
          resultColor = AppColors.danger;
        });
        return;
      }

      final cameraFaces = await detectFaces(cameraFile);

      if (cameraFaces.isEmpty) {
        setState(() {
          loading = false;
          resultTitle = "Yüz bulunamadı";
          resultSubtitle = "Daha net ve aydınlık fotoğraf çek.";
          resultIcon = Icons.face_retouching_off_rounded;
          resultColor = AppColors.danger;
        });
        return;
      }

      final cameraSig = faceSignature(cameraFaces.first);

      if (cameraSig == null) {
        setState(() {
          loading = false;
          resultTitle = "Yüz net okunamadı";
          resultSubtitle = "Yüz kameraya dönük olsun.";
          resultIcon = Icons.warning_rounded;
          resultColor = AppColors.danger;
        });
        return;
      }

      double bestScore = 999;
      String matchedName = "";

      for (final item in savedPeople) {
        final person = Map<String, String>.from(jsonDecode(item));
        final personName = person["name"] ?? "";
        final personPath = person["path"] ?? "";

        if (personName.isEmpty || personPath.isEmpty) continue;

        final personFile = File(personPath);
        if (!personFile.existsSync()) continue;

        final faces = await detectFaces(personFile);
        if (faces.isEmpty) continue;

        final sig = faceSignature(faces.first);
        if (sig == null) continue;

        final diff = (cameraSig - sig).abs();

        if (diff < bestScore) {
          bestScore = diff;
          matchedName = personName;
        }
      }

      setState(() {
        loading = false;

        if (bestScore < 0.18 && matchedName.isNotEmpty) {
          resultTitle = matchedName;
          resultSubtitle = "Kayıtlı kişi eşleşti.";
          resultIcon = Icons.verified_rounded;
          resultColor = AppColors.success;
        } else {
          resultTitle = "Kişi bulunamadı";
          resultSubtitle = "Bu yüz kayıtlı kişilerle eşleşmedi.";
          resultIcon = Icons.person_off_rounded;
          resultColor = AppColors.danger;
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        resultTitle = "İşlem hatası";
        resultSubtitle = e.toString();
        resultIcon = Icons.error_rounded;
        resultColor = AppColors.danger;
      });
    }
  }

  Widget scanningOverlay() {
    if (!loading) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: scanController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: AppColors.primary.withValues(alpha: 0.08)),
            Align(
              alignment: Alignment(0, -1 + (scanController.value * 2)),
              child: Container(
                height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.85),
                      blurRadius: 22,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget resultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: loading
          ? const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text(
                  "Analiz ediliyor...",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: resultColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(resultIcon, color: resultColor, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resultTitle,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        resultSubtitle,
                        style: const TextStyle(
                          color: AppColors.subtitle,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    scanController.dispose();
    detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Kimdi?", style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 380,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Text(
                          "Henüz fotoğraf çekilmedi",
                          style: TextStyle(
                            color: AppColors.subtitle,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(selectedImage!, fit: BoxFit.cover),
                            scanningOverlay(),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              resultCard(),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : openCamera,
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text(
                    "Kamera ile Tara",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}