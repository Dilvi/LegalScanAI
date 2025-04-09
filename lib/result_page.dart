import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResultPage extends StatefulWidget {
  final String analyzedText;

  const ResultPage({super.key, required this.analyzedText});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.analyzedText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset("assets/back_button.svg", width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Результат анализа",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SelectableText.rich(
            _formatAnalyzedText(widget.analyzedText),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPanel(context),
    );
  }

  TextSpan _formatAnalyzedText(String text) {
    List<TextSpan> spans = [];
    bool isRecommendationBlock = false;

    for (String line in text.split('\n')) {
      if (line.startsWith('💬 Рекомендация от GPT-4o-mini:')) {
        spans.add(const TextSpan(
          text: '\n💬 Рекомендация от GPT-4o-mini:\n',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ));
        isRecommendationBlock = true;
        continue;
      }

      if (isRecommendationBlock) {
        if (line.startsWith('<h2>') && line.endsWith('</h2>')) {
          spans.add(TextSpan(
            text: '\n${line.replaceAll('<h2>', '').replaceAll('</h2>', '')}\n',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ));
        } else if (line.startsWith('• ')) {
          spans.add(TextSpan(
            text: '$line\n',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ));
        } else if (line.contains('<b>') && line.contains('</b>')) {
          spans.add(TextSpan(
            text: '${line.replaceAll('<b>', '').replaceAll('</b>', '')}\n',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ));
        } else {
          spans.add(TextSpan(
            text: '$line\n',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ));
        }
      } else {
        spans.add(TextSpan(
          text: '$line\n',
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ));
      }
    }
    return TextSpan(children: spans);
  }

  Widget _buildBottomPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF800000),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21), // как на home_page
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSquare("Расширенный\nанализ", "assets/advanced_analysis_icon.svg", () {}),
              _buildSquare("Сохранить", "assets/save_icon.svg", () {}),
              _buildSquare("Поделиться", "assets/share_icon.svg", () {}),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSquare(String label, String iconPath, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.red.withOpacity(0.2),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  color: const Color(0xFF800000),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 74,
          height: 34,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
