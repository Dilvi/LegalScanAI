import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'result_page.dart';
import '../services/api_service.dart';
import 'load.dart';

class ScanDocumentPage extends StatefulWidget {
  final String docType; // ✅ добавлено

  const ScanDocumentPage({super.key, required this.docType});

  @override
  _ScanDocumentPageState createState() => _ScanDocumentPageState();
}

class _ScanDocumentPageState extends State<ScanDocumentPage> {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;
  final bool _isProcessing = false; // Флаг отображения процесса
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
          builder: (context) => const LoadPage(loadingText: "Распознаём изображение"),
        ),
      );

      print("📸 Начало процесса фотографирования...");
      final XFile image = await _cameraController!.takePicture();
      print("✅ Фотография сделана: ${image.path}");

      // ✅ Передаём docType в анализ
      final result = await ApiService.analyzeImage(
        image.path,
        docType: widget.docType,
      );

      Navigator.pop(context);
      _navigateToResult(context, result);
    } catch (e) {
      print("❌ Ошибка при съёмке или распознавании: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoadPage(loadingText: "Открываем галерею"),
        ),
      );

      print("🖼 Открытие галереи...");
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print("✅ Изображение выбрано: ${pickedFile.path}");

        // ✅ Передаём docType в анализ
        final result = await ApiService.analyzeImage(
          pickedFile.path,
          docType: widget.docType,
        );

        Navigator.pop(context);
        _navigateToResult(context, result);
      } else {
        print("⚠️ Изображение не выбрано.");
        Navigator.pop(context);
      }
    } catch (e) {
      print("❌ Ошибка при выборе изображения: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
      Navigator.pop(context);
    }
  }

  void _navigateToResult(BuildContext context, String result) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          analyzedText: result,
          docType: widget.docType, // ✅ передаём тип документа
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          "Сканирование • ${widget.docType}", // ✅ отображаем выбранный тип
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/flash_button.svg",
              width: 30,
              height: 30,
              color: _isFlashOn ? Colors.yellow : Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
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

          // Индикатор загрузки поверх камеры
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

          // Рамка сканирования
          Align(
            alignment: const Alignment(0, -0.3),
            child: SvgPicture.asset(
              "assets/photo_frame.svg",
              width: 450,
              height: 450,
            ),
          ),

          // Нижняя панель
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Color(0xFF800000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 60),

                    // Кнопка фотографирования
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await _captureAndAnalyze(context);
                        },
                        borderRadius: BorderRadius.circular(50),
                        splashColor: Colors.white.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 25),
                          child: SvgPicture.asset(
                            "assets/photo_button.svg",
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ),

                    // Кнопка галереи
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await _pickImageFromGallery(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.white.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Image.asset(
                            "assets/gallery_button.png",
                            width: 70,
                            height: 70,
                          ),
                        ),
                      ),
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
