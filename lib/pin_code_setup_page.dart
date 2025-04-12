import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCodeSetupPage extends StatefulWidget {
  const PinCodeSetupPage({super.key});

  @override
  State<PinCodeSetupPage> createState() => _PinCodeSetupPageState();
}

class _PinCodeSetupPageState extends State<PinCodeSetupPage> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;

  void _onKeyPressed(String value) {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.length < 4) {
          _confirmPin += value;
        }
      } else {
        if (_firstPin.length < 4) {
          _firstPin += value;
        }
        if (_firstPin.length == 4) {
          _isConfirming = true;
        }
      }
    });

    if (_isConfirming && _confirmPin.length == 4) {
      if (_firstPin == _confirmPin) {
        _savePin(_firstPin);
      } else {
        _showError("PIN-коды не совпадают");
        setState(() {
          _firstPin = '';
          _confirmPin = '';
          _isConfirming = false;
        });
      }
    }
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (!_isConfirming && _firstPin.isNotEmpty) {
        _firstPin = _firstPin.substring(0, _firstPin.length - 1);
      }
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_code', pin);
    await prefs.setBool('pin_enabled', true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PIN-код успешно установлен")),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  List<Widget> _buildDots() {
    final length = _isConfirming ? _confirmPin.length : _firstPin.length;
    return List.generate(4, (index) {
      return Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: index < length ? const Color(0xFF800000) : const Color(0xFFBDBDBD),
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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Установка PIN-кода"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              _isConfirming ? "Повторите PIN-код" : "Введите PIN-код",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildDots(),
            ),
            const SizedBox(height: 40),
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }
}
