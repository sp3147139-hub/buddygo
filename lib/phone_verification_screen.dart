// lib/phone_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_verification_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String password;

  const PhoneVerificationScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
      return 'Enter a valid Indian mobile number';
    }
    return null;
  }

  void _handleSendOTP() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final fullPhoneNumber = '+91${_phoneController.text.trim()}';

      // Navigate to OTP screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            fullName: widget.fullName,
            email: widget.email,
            password: widget.password,
            phoneNumber: fullPhoneNumber,
          ),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
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
                        SizedBox(height: screenHeight * 0.06),
                        // Main headline
                        const Text(
                          'Verify Your\nPhone',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4A3A),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Phone number field
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                enabled: !_isLoading,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  hintText: 'Enter Your Phone Number',
                                  hintStyle:
                                  const TextStyle(color: Color(0xFF9CA3AF)),
                                  prefixIcon: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 16),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.phone,
                                            color: Color(0xFF9CA3AF), size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          '+91',
                                          style: TextStyle(
                                            color: Color(0xFF2D4A3A),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '|',
                                          style: TextStyle(
                                            color: Color(0xFF9CA3AF),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                validator: _validatePhone,
                              ),
                              const SizedBox(height: 24),
                              // Send OTP button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSendOTP,
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
                                    'Send OTP',
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
          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D4A3A)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
