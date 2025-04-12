import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_code_setup_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool isPinEnabled = false;
  bool pinExists = false;

  @override
  void initState() {
    super.initState();
    _loadPinSetting();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPinSetting(); // обновлять при возвращении
  }

  Future<void> _loadPinSetting() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey('pin_code');
    setState(() {
      isPinEnabled = prefs.getBool('pin_enabled') ?? false;
      pinExists = exists;
    });
  }

  Future<void> _togglePinSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const PinCodeSetupPage()),
      );
      if (result == true) {
        await prefs.setBool('pin_enabled', true);
        setState(() {
          isPinEnabled = true;
          pinExists = true;
        });
      }
    } else {
      await prefs.setBool('pin_enabled', false);
      await prefs.remove('pin_code');
      setState(() {
        isPinEnabled = false;
        pinExists = false;
      });
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController1 = TextEditingController();
    final newPasswordController2 = TextEditingController();
    final pageController = PageController();
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: 270, // уменьшенная высота
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Шаг 1 — Текущий пароль
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Введите текущий пароль",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Текущий пароль",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: loading
                                ? null
                                : () async {
                              setModalState(() => loading = true);
                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null && user.email != null) {
                                  final cred = EmailAuthProvider.credential(
                                    email: user.email!,
                                    password: currentPasswordController.text.trim(),
                                  );
                                  await user.reauthenticateWithCredential(cred);
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              } catch (_) {
                                Navigator.pop(context);
                                _showPasswordResetDialog();
                              } finally {
                                setModalState(() => loading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Далее",
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                color: Colors.white, // ✅ белый текст
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Шаг 2 — Новый пароль
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Введите новый пароль дважды",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController1,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Новый пароль",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: newPasswordController2,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Повторите пароль",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (newPasswordController1.text.trim() !=
                                  newPasswordController2.text.trim()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Пароли не совпадают"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              try {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await user.updatePassword(
                                    newPasswordController1.text.trim(),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Пароль успешно обновлён"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (_) {
                                Navigator.pop(context);
                                _showPasswordResetDialog();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF800000),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Сменить пароль",
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                color: Colors.white, // ✅ белый текст
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ошибка авторизации"),
        content: const Text("Текущий пароль неверен. Сбросить пароль через email?"),
        actions: [
          TextButton(
            child: const Text("Отмена"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Сбросить"),
            onPressed: () async {
              Navigator.pop(context);
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && user.email != null) {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: user.email!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Письмо для сброса отправлено")),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset('assets/back_button.svg', width: 24, height: 24),
        ),
        centerTitle: true,
        title: const Text(
          'Безопасность и вход',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: ListView(
          children: [
            const Text(
              "Вход по PIN-коду",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              value: isPinEnabled,
              onChanged: (val) => _togglePinSetting(val),
              activeColor: const Color(0xFF800000),
              contentPadding: EdgeInsets.zero,
              title: const Text(
                "Включить/отключить PIN",
                style: TextStyle(fontFamily: 'DM Sans'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: pinExists
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PinCodeSetupPage()),
                  );
                }
                    : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF800000)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Сменить PIN-код",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                    color: pinExists ? const Color(0xFF800000) : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Смена пароля",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showChangePasswordDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF800000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Сменить пароль",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // ✅ белый текст
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
