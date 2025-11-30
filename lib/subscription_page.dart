import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  Map<String, dynamic>? subscription;
  bool loading = true;

  // тариф теперь приходит из display_name → не переводим
  String translatePlan(dynamic raw) {
    if (raw == null) return "Нет активной подписки";
    return raw.toString();
  }

  // форматирование ISO
  String formatExpiry(String isoString) {
    try {
      final dt = DateTime.parse(isoString);

      const months = [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря"
      ];

      final month = months[dt.month - 1];

      return "${dt.day} $month ${dt.year}";
    } catch (e) {
      return isoString;
    }
  }


  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  // ============================================================
  // LOAD USER SUBSCRIPTION
  // ============================================================
  Future<void> _loadSubscription() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final res = await http.get(
      Uri.parse("http://95.165.74.131:8080/profile/get"),
      headers: {"Authorization": token ?? ""},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      setState(() {
        subscription = data["subscription"];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  // ============================================================
  // BUY SUBSCRIPTIONS
  // ============================================================
  Future<void> _buy(String endpoint) async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    final res = await http.post(
      Uri.parse("http://95.165.74.131:8080/subscription/$endpoint"),
      headers: {"Authorization": token ?? ""},
    );

    await _loadSubscription();

    if (!mounted) return;

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Подписка активирована"),
          backgroundColor: Color(0xFF800000),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ошибка активации"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onTabTap(int index) {
    setState(() => currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // PAGE BUILDING
  // ============================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF800000)),
        ),
      );
    }

    final hasSub = subscription != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset('assets/back_button.svg',
              width: 24, height: 24),
        ),
        centerTitle: true,
        title: Text(
          hasSub ? 'Моя подписка' : 'Подключить PRO',
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: hasSub ? _buildMySubscription() : _buildSubscriptionSelector(),
    );
  }

  // ============================================================
  // MY SUBSCRIPTION PAGE
  // ============================================================
  Widget _buildMySubscription() {
    final plan = subscription!["plan"];
    final expiry = subscription!["expiry"];

    /// ✔ ВАЖНО: backend отдаёт "requestsLeft", а НЕ "requests_left"
    final requestsLeft = subscription!["requestsLeft"];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF3F3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Текущий тариф",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  color: Color(0xFF800000),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                translatePlan(plan),
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Подписка активна до: ${formatExpiry(expiry)}",
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _limitTile("Оставшиеся запросы", requestsLeft),

        const SizedBox(height: 30),
        const Divider(),

        const SizedBox(height: 20),
        const Text(
          "Хочу сменить тариф",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),
        _buildBoostButton(
            "Перейти на годовую подписку", () => _buy("buy/yearly")),

        const SizedBox(height: 30),
        const Divider(),

        const SizedBox(height: 20),
        const Text(
          "Хотите докупить запросы?",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),
        _buildBoostButton("10 запросов", () => _buy("boost/10")),
        const SizedBox(height: 10),
        _buildBoostButton("30 запросов", () => _buy("boost/30")),
        const SizedBox(height: 10),
        _buildBoostButton("50 запросов", () => _buy("boost/50")),
        const SizedBox(height: 10),
        _buildBoostButton("100 запросов", () => _buy("boost/100")),
      ],
    );
  }

  Widget _limitTile(String title, dynamic value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
              )),
          Text(
            value == null ? "♾ Безлимит" : value.toString(),
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostButton(String title, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800000),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBSCRIPTION SELECTOR PAGE
  // ============================================================
  Widget _buildSubscriptionSelector() {
    return Column(
      children: [
        _buildHeaderInfo(),
        const SizedBox(height: 10),
        _buildFeatureCard(),
        const SizedBox(height: 16),
        _buildTabSwitcher(),
        const SizedBox(height: 8),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) =>
                setState(() => currentIndex = index),
            children: [
              _buildSubscriptionOptions(),
              _buildTokensOptions(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Экономьте время, избегайте ошибок, получайте готовые юридические разъяснения за минуты.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: Color(0xFF800000),
        ),
      ),
    );
  }

  Widget _buildFeatureCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Что входит в PRO:",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF800000),
              ),
            ),
            const SizedBox(height: 14),
            _proFeature("⚖️ Глубокий анализ юридических документов"),
            _proFeature("📚 Разъяснения по закону с примерами"),
            _proFeature("📘 Подробные инструкции по ситуациям"),
            _proFeature("📄 Доступ к правовой базе"),
            _proFeature("🚀 Приоритетная обработка"),
            _proFeature("♾️ Безлимит (в годовой подписке)"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildTab("Подписка", 0),
            _buildTab("Запросы", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF800000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),

        _buildOptionTile(
          "Месячная подписка",
          "30 дней доступа · 30 универсальных запросов",
              () => _buy("buy/monthly"),
        ),

        const SizedBox(height: 10),

        _buildOptionTile(
          "Годовая подписка",
          "12 месяцев доступа · приоритет · без ограничений",
              () => _buy("buy/yearly"),
        ),
      ],
    );
  }

  Widget _buildTokensOptions() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),
        _buildOptionTile(
          "10 запросов",
          "Дополнительно 10 запросов",
              () => _buy("boost/10"),
        ),
        const SizedBox(height: 10),
        _buildOptionTile(
          "30 запросов",
          "Дополнительно 30 запросов",
              () => _buy("boost/30"),
        ),
        const SizedBox(height: 10),
        _buildOptionTile(
          "50 запросов",
          "Дополнительно 50 запросов",
              () => _buy("boost/50"),
        ),
        const SizedBox(height: 10),
        _buildOptionTile(
          "100 запросов",
          "Дополнительно 100 запросов",
              () => _buy("boost/100"),
        ),
      ],
    );
  }

  Widget _buildOptionTile(String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF800000), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Color(0xFF800000)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _proFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
