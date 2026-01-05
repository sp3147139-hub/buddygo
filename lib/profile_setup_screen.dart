// lib/profile_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'home.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }

        // Store profile data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': user.displayName,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
          'hasProfilePicture': _selectedImage != null,
          'profileCompleted': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile setup completed!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate to Home
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Login_Page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            color: const Color(0xFFD4E8D4).withValues(alpha: 0.3),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.06),
                        // Logo and App Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Image.asset(
                                'assets/icon/BuddyGo.png',
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Text(
                              'BuddyGo',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D4A3A),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // Main headline
                        const Text(
                          'Setup Your Profile',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4A3A),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // Profile Photo
                        GestureDetector(
                          onTap: _isLoading ? null : _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE67E40),
                                width: 3,
                              ),
                            ),
                            child: _selectedImage != null
                                ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Color(0xFF4A5F52),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D4A3A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Username field
                              TextFormField(
                                controller: _usernameController,
                                keyboardType: TextInputType.text,
                                enabled: !_isLoading,
                                decoration: const InputDecoration(
                                  hintText: 'Choose Username',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                                validator: _validateUsername,
                              ),
                              const SizedBox(height: 16),
                              // Bio field
                              TextFormField(
                                controller: _bioController,
                                keyboardType: TextInputType.multiline,
                                enabled: !_isLoading,
                                maxLines: 3,
                                maxLength: 150,
                                decoration: const InputDecoration(
                                  hintText:
                                  'Tell us about yourself...\n(your adventures, interests, bio)',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Complete Setup button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                  _isLoading ? null : _completeSetup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE67E40),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                    const Color(0xFFE67E40)
                                        .withValues(alpha: 0.6),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                      : const Text(
                                    'Complete Setup',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
