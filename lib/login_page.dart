import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    final success = await AuthService().login(email, password);

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      _showError("Ошибка входа. Проверьте данные.");
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
                  "ВОЙДИТЕ В АККАУНТ",
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
                  "Введите email и пароль, чтобы получить доступ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: Color(0xFF737C97),
                  ),
                ),

                const SizedBox(height: 32),

                // ---- EMAIL ----
                _buildTextField(
                  label: 'Email адрес',
                  controller: _emailController,
                  isFocused: _isEmailFocused,
                  onFocusChange: (hasFocus) {
                    setState(() => _isEmailFocused = hasFocus);
                  },
                ),

                const SizedBox(height: 32),

                // ---- PASSWORD ----
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
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF800000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Войти",
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
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: 'Нет аккаунта? ',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        color: Color(0xFF737C97),
                      ),
                      children: [
                        TextSpan(
                          text: 'Регистрация',
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
