import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? "";
      _nameController.text = user.displayName ?? "";
      // For phone number, retrieve it from your backend if available.
      _phoneController.text = "";
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(_nameController.text);
        // Optionally, update phone number in your backend if needed.
        await user.reload();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user and its photoURL.
    final user = FirebaseAuth.instance.currentUser;
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            children: [
              // Profile picture with a circular border and shadow, and edit button
              Semantics(
                label: 'Profile picture',
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            photoUrl == null ? Colors.black87 : Colors.transparent,
                        backgroundImage:
                            photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? (user?.displayName != null &&
                                    user!.displayName!.isNotEmpty
                                ? Text(
                                    user.displayName![0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 60,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Icon(Icons.person,
                                    size: 60, color: Colors.white))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Semantics(
                        label: 'Edit profile picture',
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                            if (picked != null) {
                              setState(() => _isLoading = true);
                              try {
                                // Upload to Firebase Storage or your backend, then get the URL
                                // For demo, use local file path (not for production)
                                // In production, upload to storage and get the download URL
                                await user?.updatePhotoURL(picked.path);
                                await user?.reload();
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Photo updated!")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error updating photo: $e")),
                                );
                              }
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.blueAccent, size: 22),
                          ),
                        ),
                      ),
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Divider(thickness: 1.2, color: Colors.blueAccent.withOpacity(0.2)),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ),
              const SizedBox(height: 16),
              // Name text field.
              Semantics(
                label: 'Name field',
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Email text field (visible but read-only).
              Semantics(
                label: 'Email field',
                child: TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone number text field.
              Semantics(
                label: 'Phone number field',
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Update Profile button.
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
