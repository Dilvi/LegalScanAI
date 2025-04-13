import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'load.dart';
import 'no_connection.dart';

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

  bool _isSaveButtonEnabled = false;
  bool _isLoading = true;
  bool _hasError = false;

  String _initialName = '';
  String _initialSurname = '';
  String _initialEmail = '';
  String _initialPhone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _setupListeners();
  }

  void _setupListeners() {
    _nameController.addListener(_checkIfChanged);
    _surnameController.addListener(_checkIfChanged);
    _emailController.addListener(_checkIfChanged);
    _phoneController.addListener(_checkIfChanged);
  }

  void _checkIfChanged() {
    setState(() {
      _isSaveButtonEnabled = _nameController.text.trim() != _initialName ||
          _surnameController.text.trim() != _initialSurname ||
          _emailController.text.trim() != _initialEmail ||
          _phoneController.text.trim() != _initialPhone;
    });
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          _initialName = userDoc['name'] ?? '';
          _initialSurname = userDoc['surname'] ?? '';
          _initialEmail = userDoc['email'] ?? '';
          _initialPhone = userDoc['phone'] ?? '';

          _nameController.text = _initialName;
          _surnameController.text = _initialSurname;
          _emailController.text = _initialEmail;
          _phoneController.text = _initialPhone;

          _isSaveButtonEnabled = false;
        }

        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      print("Ошибка при загрузке данных: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _saveUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text.trim(),
          'surname': _surnameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Данные успешно сохранены')),
        );

        setState(() {
          _initialName = _nameController.text.trim();
          _initialSurname = _surnameController.text.trim();
          _initialEmail = _emailController.text.trim();
          _initialPhone = _phoneController.text.trim();
          _isSaveButtonEnabled = false;
        });
      }
    } catch (e) {
      print("Ошибка при сохранении данных: $e");
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    if (_isLoading) {
      return const LoadPage(loadingText: "Соединение с сервером");
    }

    if (_hasError) {
      return const NoConnectionPage();
    }

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
                        onPressed: _isSaveButtonEnabled
                            ? () {
                          if (_formKey.currentState!.validate()) {
                            _saveUserData();
                          }
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaveButtonEnabled ? const Color(0xFF800000) : Colors.grey,
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
