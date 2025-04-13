import 'package:flutter/material.dart';
import 'dart:async';

class LoadPage extends StatefulWidget {
  final String loadingText;

  const LoadPage({super.key, this.loadingText = "Анализируем ваш документ"});

  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    // Таймер для анимации точек
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Гифка загрузки
            SizedBox(
              width: screenWidth * 0.6,
              height: screenWidth * 0.6,
              child: Image.asset(
                "assets/load.gif",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // Текст с анимацией точек
            Container(
              width: screenWidth * 0.8,
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF800000),
                  ),
                  children: [
                    TextSpan(text: "${widget.loadingText},\nодну минуту"),
                    TextSpan(text: "." * _dotCount + " " * (3 - _dotCount)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
