import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ChatBot extends StatefulWidget {
  ChatBot({Key? key}) : super(key: key);

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isOpen = false;

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _messageController.clear();
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/chatbot/faq/questions/?search=${Uri.encodeComponent(text)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply;
        if (data.isNotEmpty && data[0]['answers'] != null && data[0]['answers'].isNotEmpty) {
          reply = data[0]['answers'][0]['text'];
        } else {
          reply = 'Sorry, I couldn\'t find an answer. Please try asking differently or submit a new question.';
        }
        setState(() {
          _messages.add({'text': reply, 'isUser': false});
        });
      } else {
        setState(() {
          _messages.add({'text': 'Error fetching answer: ${response.statusCode}', 'isUser': false});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error fetching answer: $e', 'isUser': false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Stack(
      children: [
        if (_isOpen)
          Positioned(
            right: 24,
            bottom: 90,
            width: 340,
            height: 480,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(20),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: colorScheme.primary.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.white, size: 28),
                          const SizedBox(width: 10),
                          Text(
                            'StaySpot Chatbot',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _toggleChat,
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: colorScheme.surface,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser = message['isUser'] as bool;
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                constraints: BoxConstraints(maxWidth: 220),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? colorScheme.primary.withOpacity(0.12)
                                      : colorScheme.secondary.withOpacity(0.13),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isUser ? 16 : 4),
                                    topRight: Radius.circular(isUser ? 4 : 16),
                                    bottomLeft: const Radius.circular(16),
                                    bottomRight: const Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    color: isUser
                                        ? colorScheme.primary.withOpacity(0.18)
                                        : colorScheme.secondary.withOpacity(0.18),
                                  ),
                                ),
                                child: Text(
                                  message['text'],
                                  style: GoogleFonts.poppins(
                                    color: isUser ? colorScheme.primary : colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: GoogleFonts.poppins(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Ask a question...'
                                    ,
                                hintStyle: GoogleFonts.poppins(color: colorScheme.onSurface.withOpacity(0.5)),
                                filled: true,
                                fillColor: colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.18)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.18)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                              tooltip: 'Send',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: _toggleChat,
            backgroundColor: colorScheme.primary,
            child: Icon(_isOpen ? Icons.close : Icons.smart_toy, color: Colors.white),
            tooltip: _isOpen ? 'Close Chatbot' : 'Open Chatbot',
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
} 