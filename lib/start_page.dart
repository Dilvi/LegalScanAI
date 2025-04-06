import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> _pages = [
    {
      "title": "ПРОВЕРЯЙТЕ ДОКУМЕНТЫ\nПЕРЕД ПОДПИСАНИЕМ",
      "subtitle": "Неочевидные условия могут привести к финансовым и юридическим рискам. Будьте уверены в каждом пункте договора!",
      "image": "assets/start_icon_1.png",
    },
    {
      "title": "СКАНИРУЙТЕ ПРИ ПОМОЩИ ТЕЛЕФОНА",
      "subtitle": "Система распознавания проанализирует документ и отправит текст на анализ нейросети",
      "image": "assets/start_icon_2.png",
    },
    {
      "title": "LegalMind\nAI помощник по праву",
      "subtitle": "Подскажет, как действовать, если контролёр требует оплату без квитанции, ГИБДД останавливает без причины или автобус не приезжает по расписанию",
      "image": "assets/start_icon_3.png",
    },
    {
      "title": "ВАШИ ДАННЫЕ\nВ БЕЗОПАСНОСТИ",
      "subtitle": "Документ анализирует локальная нейросеть на вашем устройстве и не допустит утечки конфиденциальных данных",
      "image": "assets/start_icon_4.png",
    },
  ];

  void _nextPage() {
    if (_pageController.page! < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * scale),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _pages[index]["image"]!,
                        width: 180 * scale,
                        height: 180 * scale,
                      ),
                      SizedBox(height: 30 * scale),
                      Text(
                        _pages[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        _pages[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14 * scale,
                          color: const Color(0xFF737C97),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 2.2,
                  activeDotColor: const Color(0xFF800000),
                  dotColor: const Color(0xFF8C8C8C).withOpacity(0.3),
                ),
              ),
              SizedBox(height: 30 * scale),
              ElevatedButton.icon(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  minimumSize: Size(double.infinity, 52 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  (_pageController.hasClients && _pageController.page == _pages.length - 1)
                      ? "Начать"
                      : "Далее",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 24 * scale),
            ],
          ),
        ),
      ),
    );
  }
}
