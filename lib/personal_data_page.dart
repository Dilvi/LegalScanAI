import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/profile_service.dart';
import 'load.dart';
import 'no_connection.dart';

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key});

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSaveButtonEnabled = false;
  bool _isLoading = true;
  bool _hasError = false;

  String _initialFullName = '';
  String _initialEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupListeners();
  }

  void _setupListeners() {
    for (var controller in [
      _fullNameController,
      _emailController,
    ]) {
      controller.addListener(_checkIfChanged);
    }
  }

  void _checkIfChanged() {
    setState(() {
      _isSaveButtonEnabled =
          _fullNameController.text.trim() != _initialFullName ||
              _emailController.text.trim() != _initialEmail;
    });
  }

  Future<void> _loadUserData() async {
    final data = await ProfileService.getProfile();
    if (data == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    setState(() {
      _initialFullName = data['fullName'] ?? '';
      _initialEmail = data['email'] ?? '';

      _fullNameController.text = _initialFullName;
      _emailController.text = _initialEmail;

      _isLoading = false;
      _hasError = false;
      _isSaveButtonEnabled = false;
    });
  }

  Future<void> _saveUserData() async {
    final success = await ProfileService.updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Данные успешно сохранены')),
      );
      setState(() {
        _initialFullName = _fullNameController.text.trim();
        _initialEmail = _emailController.text.trim();
        _isSaveButtonEnabled = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении данных')),
      );
    }
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
        Text(label,
            style: const TextStyle(
                fontFamily: 'DM Sans', fontSize: 14, color: Colors.black)),
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
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Поле не может быть пустым'
              : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadPage(loadingText: "Соединение с сервером");
    if (_hasError) return const NoConnectionPage();

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
                    label: 'Имя и фамилия',
                    hint: 'Введите полное имя',
                    controller: _fullNameController,
                  ),
                  _buildTextField(
                    label: 'Email',
                    hint: 'Введите email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: 327,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaveButtonEnabled
                            ? () {
                          if (_formKey.currentState!.validate()) {
                            _saveUserData();
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaveButtonEnabled
                              ? const Color(0xFF800000)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
