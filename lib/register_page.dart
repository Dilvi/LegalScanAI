import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailFocused = false;
  bool _isPhoneFocused = false;
  bool _isPasswordFocused = false;

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      User? user = await AuthService().register(email, password, phone);

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        _showError("Не удалось создать аккаунт. Проверьте данные.");
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'Этот email уже используется.';
          break;
        case 'invalid-email':
          errorMsg = 'Неверный формат email.';
          break;
        case 'weak-password':
          errorMsg = 'Пароль слишком слабый.';
          break;
        default:
          errorMsg = 'Ошибка регистрации: ${e.message}';
      }
      _showError(errorMsg);
    } catch (e) {
      if (!mounted) return;
      _showError("Неизвестная ошибка: $e");
    }
  }












  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                const Text(
                  "СОЗДАЙТЕ АККАУНТ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 20,
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Введите правильные данные, чтобы\nправильно настроить свою учетную\nзапись.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Color(0xFF737C97),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Email адрес',
                  controller: _emailController,
                  isFocused: _isEmailFocused,
                  onFocusChange: (hasFocus) {
                    setState(() => _isEmailFocused = hasFocus);
                  },
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Номер телефона',
                  controller: _phoneController,
                  isFocused: _isPhoneFocused,
                  onFocusChange: (hasFocus) {
                    setState(() => _isPhoneFocused = hasFocus);
                  },
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  label: 'Пароль',
                  controller: _passwordController,
                  obscureText: true,
                  isFocused: _isPasswordFocused,
                  onFocusChange: (hasFocus) {
                    setState(() => _isPasswordFocused = hasFocus);
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: screenWidth * 0.9,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Создать аккаунт",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Уже есть аккаунт? ',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Color(0xFF737C97),
                      ),
                      children: [
                        TextSpan(
                          text: 'Войти',
                          style: TextStyle(
                            color: Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    required bool isFocused,
    required Function(bool) onFocusChange,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: isFocused ? label : null,
          hintText: !isFocused ? label : null,
          labelStyle: TextStyle(
            fontSize: isFocused ? 16 : 14,
            color: isFocused ? const Color(0xFF800000) : const Color(0xFF737C97),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF737C97),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFDFE2E6), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF800000), width: 2),
          ),
        ),
      ),
    );
  }
}
