import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = []; // {'role': 'user'/'bot', 'text': '...'}

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _messages.add({'role': 'bot', 'text': _getBotReply(text)});
      _controller.clear();
    });
  }

  String _getBotReply(String userInput) {
    // Заглушка. Здесь будет подключение к LegalMind.
    return 'Это предварительный ответ от LegalMind по теме: "$userInput"';
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Задайте свой вопрос — LegalMind готов помочь!',
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.grey[600],
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16 * scale),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6 * scale),
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
                    constraints: BoxConstraints(maxWidth: 280 * scale),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFE6F0FF) : const Color(0xFFF5F5F5),
                      border: isUser ? null : Border.all(color: const Color(0xFF800000)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text']!,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'DM Sans',
                        fontSize: 14 * scale,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Быстрые кнопки
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
          // Поле ввода
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