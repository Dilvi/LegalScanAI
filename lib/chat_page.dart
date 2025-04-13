import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user'/'bot', 'text': '...'}
  bool _isLoading = false;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();

    // 👋 Приветственное сообщение
    _messages.add({
      'role': 'bot',
      'text': """
**👋 Добро пожаловать в LegalMind!**

Я — ваш виртуальный адвокат и помощник по правам. Я помогу вам:

- 🚓 Понять, что делать при задержании;
- 🛂 Узнать, если сотрудник превышает полномочия;
- 🚌 Защитить свои права как пассажира;
- 🚗 Правильно себя вести при остановке ГИБДД;
- ⚖️ Получить советы на основе Конституции и Гражданского кодекса РФ.

Просто задайте свой вопрос — и я помогу вам разобраться в ситуации.
"""
    });


    // ⏳ Анимация точек
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || !_isLoading) return;
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _controller.clear();
      _isLoading = true;
    });

    final botReply = await ApiService.sendMessage(text);

    setState(() {
      _isLoading = false;
      _messages.add({'role': 'bot', 'text': botReply});
    });
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LegalMind',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16 * scale),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6 * scale),
                      padding: EdgeInsets.all(12 * scale),
                      constraints: BoxConstraints(maxWidth: 280 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        border: Border.all(color: const Color(0xFF800000)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF800000),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Генерируем ответ${'.' * _dotCount}',
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final message = _messages[_messages.length - 1 - index + (_isLoading ? 1 : 0)];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: message['text'] ?? ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сообщение скопировано')),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6 * scale),
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
                      constraints: BoxConstraints(maxWidth: 280 * scale),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFFE6F0FF) : const Color(0xFFF5F5F5),
                        border: isUser ? null : Border.all(color: const Color(0xFF800000)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MarkdownBody(
                        data: message['text']!,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            fontSize: 14 * scale,
                            color: Colors.black,
                            fontFamily: 'DM Sans',
                          ),
                          strong: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontFamily: 'DM Sans',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 42 * scale,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              children: [
                _buildQuickButton('🚓 Права при задержании', scale),
                _buildQuickButton('🚌 Права пассажира', scale),
                _buildQuickButton('⚖️ Консультация по ГК РФ', scale),
                _buildQuickButton('🚗 Остановка ГИБДД', scale),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Напишите свой вопрос...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF800000)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF800000), width: 2),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  InkWell(
                    onTap: () => _sendMessage(_controller.text),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: EdgeInsets.all(10 * scale),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF800000),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickButton(String label, double scale) {
    return Padding(
      padding: EdgeInsets.only(right: 8 * scale),
      child: ElevatedButton(
        onPressed: () => _sendMessage(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 14 * scale),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF800000), width: 1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13 * scale,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
    );
  }
}
