import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometricsEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 360;

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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 10 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Настройки безопасности",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20 * scale),
              _buildSwitchTile(
                label: 'Разрешить вход с помощью Face ID / отпечатка',
                value: _biometricsEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                label: 'Двухфакторная аутентификация',
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text(
                "Изменить пароль",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordButton("Сменить текущий пароль"),
              const SizedBox(height: 12),
              _buildPasswordButton("Сбросить через email"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF800000)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF800000),
        title: Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordButton(String title) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // TODO: обработка нажатия
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF800000),
          side: const BorderSide(color: Color(0xFF800000)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
