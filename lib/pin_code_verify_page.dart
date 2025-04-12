import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';

class PinCodeVerifyPage extends StatefulWidget {
  const PinCodeVerifyPage({super.key});

  @override
  State<PinCodeVerifyPage> createState() => _PinCodeVerifyPageState();
}

class _PinCodeVerifyPageState extends State<PinCodeVerifyPage> {
  String _enteredPin = '';

  void _onKeyPressed(String value) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });

      if (_enteredPin.length == 4) {
        _checkPin(_enteredPin);
      }
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _checkPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('pin_code') ?? '';
    await Future.delayed(const Duration(milliseconds: 200)); // Для плавности

    if (pin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() => _enteredPin = '');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Неверный PIN-код"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetPin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Сброс PIN-кода"),
        content: const Text("Это удалит все проверки и выйдет из аккаунта. Продолжить?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Сбросить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pin_code');
      await prefs.remove('pin_enabled');
      await prefs.remove('recentChecks');

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );
      }
    }
  }

  List<Widget> _buildDots() {
    return List.generate(4, (index) {
      return Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index < _enteredPin.length ? const Color(0xFF800000) : const Color(0xFFBDBDBD),
        ),
      );
    });
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyPressed(value),
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF800000), width: 2),
          borderRadius: BorderRadius.circular(35),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF800000),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key == '⌫') {
              return GestureDetector(
                onTap: _onDelete,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF800000), width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.backspace, color: Color(0xFF800000)),
                  ),
                ),
              );
            } else if (key.isEmpty) {
              return const SizedBox(width: 70, height: 70);
            } else {
              return _buildKey(key);
            }
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Введите PIN-код",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildDots(),
            ),
            const SizedBox(height: 40),
            _buildKeyboard(),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _resetPin,
              child: const Text(
                "Сбросить PIN-код",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
