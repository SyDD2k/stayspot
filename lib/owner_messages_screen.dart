import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class OwnerMessagesScreen extends StatefulWidget {
  const OwnerMessagesScreen({super.key});

  @override
  State<OwnerMessagesScreen> createState() => _OwnerMessagesScreenState();
}

class _OwnerMessagesScreenState extends State<OwnerMessagesScreen> {
  List<dynamic> _chatRooms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<String?> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return await user?.getIdToken();
  }

  Future<void> _fetchChatRooms() async {
    setState(() => _loading = true);
    final idToken = await _getIdToken();
    if (idToken == null) {
      setState(() => _loading = false);
      return;
    }
    final url = Uri.parse('http://127.0.0.1:8000/users/api/owner/chat_rooms/');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $idToken'});
    if (response.statusCode == 200) {
      setState(() {
        _chatRooms = json.decode(response.body);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: GoogleFonts.poppins()),
        backgroundColor: Colors.blue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
              ? Center(child: Text('No messages yet.', style: GoogleFonts.poppins()))
              : ListView.builder(
                  itemCount: _chatRooms.length,
                  itemBuilder: (context, index) {
                    final room = _chatRooms[index];
                    return ListTile(
                      leading: Icon(Icons.chat_bubble_outline, color: Colors.blue),
                      title: Text(room['user_username'] ?? 'User', style: GoogleFonts.poppins()),
                      subtitle: Text('Property: ${room['property'] ?? ''}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(propertyId: room['property'].toString()),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
} 