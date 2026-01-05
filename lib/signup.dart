// lib/signup.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'phone_verification_screen.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      // Just navigate to phone verification with data (no Firebase call yet)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PhoneVerificationScreen(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        ),
      );
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
          // Subtle overlay for better readability
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
                          'Create Your\nAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4A3A),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Full Name field
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                enabled: !_isLoading,
                                textCapitalization: TextCapitalization.words,
                                decoration: const InputDecoration(
                                  hintText: 'Full Name',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                                validator: _validateName,
                              ),
                              const SizedBox(height: 16),
                              // Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !_isLoading,
                                decoration: const InputDecoration(
                                  hintText: 'Email',
                                  hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle:
                                  const TextStyle(color: Color(0xFF9CA3AF)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 24),
                              // Sign Up button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE67E40),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                    const Color(0xFFE67E40).withValues(alpha: 0.6),
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
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Terms text
                              const Text(
                                'By signing up, you agree to our Terms',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF2D4A3A),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF2D4A3A),
                                fontSize: 15,
                              ),
                            ),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Color(0xFFE67E40),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
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
