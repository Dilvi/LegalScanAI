import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Безопасно отложенный доступ к FocusScope
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        currentFocus.focusedChild!.unfocus();
      }
    });
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF800000), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF800000), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Поле не может быть пустым';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Личные данные',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Имя',
                    hint: 'Введите ваше имя',
                    controller: _nameController,
                  ),
                  _buildTextField(
                    label: 'Фамилия',
                    hint: 'Введите вашу фамилию',
                    controller: _surnameController,
                  ),
                  _buildTextField(
                    label: 'Email',
                    hint: 'Введите email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    label: 'Телефон',
                    hint: '+7 (___) ___-__-__',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 327,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: обработка сохранения данных
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Данные сохранены')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF800000),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
