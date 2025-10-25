import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'result_page.dart';
import '../services/api_service.dart';
import 'load.dart';

class ScanDocumentPage extends StatefulWidget {
  final String docType;

  const ScanDocumentPage({super.key, required this.docType});

  @override
  _ScanDocumentPageState createState() => _ScanDocumentPageState();
}

class _ScanDocumentPageState extends State<ScanDocumentPage> {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;
  final bool _isProcessing = false;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
      print("📸 Камера инициализирована успешно.");
    } catch (e) {
      print("❌ Ошибка инициализации камеры: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _cameraController?.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _captureAndAnalyze(BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const LoadPage(loadingText: "Распознаём изображение"),
        ),
      );

      final XFile image = await _cameraController!.takePicture();
      final result = await ApiService.analyzeImage(
        image.path,
        docType: widget.docType,
      );

      Navigator.pop(context);
      _navigateToResult(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Ошибка: $e")));
      Navigator.pop(context);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const LoadPage(loadingText: "Обрабатываем изображение"),
          ),
        );

        final result = await ApiService.analyzeImage(
          pickedFile.path,
          docType: widget.docType,
        );

        Navigator.pop(context);
        _navigateToResult(context, result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Ошибка: $e")));
    }
  }

  void _navigateToResult(BuildContext context, String result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          analyzedText: result,
          docType: widget.docType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset("assets/back_button.png", width: 24, height: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Сканирование",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: _isFlashOn ? Colors.amber : Colors.black,
              size: 28,
            ),
            onPressed: _toggleFlash,
            tooltip: "Вспышка",
          ),
          const SizedBox(width: 5),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Камера
          Positioned.fill(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),

          // Индикатор загрузки
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
              ),
            ),

          // 🌟 Анимированная рамка
          const Align(
            alignment: Alignment(0, -0.2),
            child: ScanningFrame(),
          ),

// Нижняя панель
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                height: 125,
                padding: const EdgeInsets.symmetric(horizontal: 21),
                decoration: const BoxDecoration(
                  color: Color(0xFF800000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 52), // небольшой отступ слева для симметрии

                        // 📸 Центральная кнопка
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await _captureAndAnalyze(context);
                            },
                            borderRadius: BorderRadius.circular(50),
                            splashColor: Colors.white.withOpacity(0.3),
                            child: SvgPicture.asset(
                              "assets/photo_button.svg",
                              width: 80,
                              height: 80,
                            ),
                          ),
                        ),

                        // 🖼 Кнопка галереи
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await _pickImageFromGallery(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.white.withOpacity(0.3),
                            child: Image.asset(
                              "assets/gallery_button.png",
                              width: 52,
                              height: 52,
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

// 🪄 Анимированная рамка сканирования
class ScanningFrame extends StatelessWidget {
  const ScanningFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.95),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1800.ms)
        .scaleXY(
      begin: 0.97,
      end: 1.02,
      duration: 1500.ms,
      curve: Curves.easeInOut,
    );
  }
}
