import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String propertyId;
  const ChatScreen({super.key, required this.propertyId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _messages = [];
  bool _loading = true;
  int? _chatRoomId;
  String? _sessionId;
  Timer? _pollingTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      await _initSessionId();
      await _initChat();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing chat: $e')),
        );
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_chatRoomId != null && !_loading && mounted) {
        _fetchMessages();
      }
    });
  }

  Future<String?> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }

  Future<void> _initSessionId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sessionId = prefs.getString('chat_session_id');
      if (sessionId == null) {
        sessionId = Uuid().v4();
        await prefs.setString('chat_session_id', sessionId);
      }
      if (mounted) {
        setState(() {
          _sessionId = sessionId;
        });
      }
    } catch (e) {
      print('Error initializing session ID: $e');
      rethrow;
    }
  }

  Future<void> _initChat() async {
    try {
      final idToken = await _getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('http://127.0.0.1:8000/users/api/chat/get_or_create/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({'property_id': widget.propertyId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _chatRoomId = data['id'];
            _loading = false;
          });
        }
        _startPolling();
        await _fetchMessages();
      } else {
        throw Exception('Failed to create chat room: ${response.body}');
      }
    } catch (e) {
      print('Error initializing chat: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize chat: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> _fetchMessages() async {
    if (_chatRoomId == null || _loading) return;
    
    try {
      setState(() => _loading = true);
      final idToken = await _getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('http://127.0.0.1:8000/users/api/chat/$_chatRoomId/messages/');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _messages = data;
            _loading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_chatRoomId == null || _controller.text.trim().isEmpty || _sessionId == null) return;
    
    try {
      final idToken = await _getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('http://127.0.0.1:8000/users/api/chat/send_message/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'chat_room_id': _chatRoomId,
          'content': _controller.text.trim(),
          'session_id': _sessionId
        }),
      );

      if (response.statusCode == 201) {
        _controller.clear();
        await _fetchMessages();
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chat with Owner', style: GoogleFonts.poppins()),
          backgroundColor: colorScheme.primary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Owner', style: GoogleFonts.poppins()),
        backgroundColor: colorScheme.primary,
      ),
      body: _loading && _messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.07),
                    colorScheme.secondary.withOpacity(0.04)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[_messages.length - 1 - index];
                        final isSender = msg['session_id'] != null && msg['session_id'] == _sessionId;
                        return Row(
                          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                top: 6,
                                bottom: 6,
                                left: isSender ? 40 : 0,
                                right: isSender ? 0 : 40,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7
                              ),
                              decoration: BoxDecoration(
                                color: isSender
                                    ? Color(0xFFB3D8FD)
                                    : Color(0xFFE3F0FB),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(isSender ? 18 : 4),
                                  bottomRight: Radius.circular(isSender ? 4 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg['content'] ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    msg['sender_username'] ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: GoogleFonts.poppins(),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: GoogleFonts.poppins(
                                  color: colorScheme.onSurface.withOpacity(0.5)
                                ),
                                filled: true,
                                fillColor: colorScheme.surface,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 16
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withOpacity(0.2)
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary.withOpacity(0.2)
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2
                                  ),
                                ),
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                              tooltip: 'Send',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 