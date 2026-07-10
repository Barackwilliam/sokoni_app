import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  Future<void> _sendOtp() async {
    final input = _phoneController.text.trim();
    if (input.length < 9) {
      _showError('Please enter a valid phone number');
      return;
    }

    String phone = input;
    if (phone.startsWith('0')) {
      phone = '+255${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+255$phone';
    }

    setState(() => _loading = true);

    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: () {
        setState(() => _loading = false);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(phoneNumber: phone),
            ));
      },
      onError: (error) {
        setState(() => _loading = false);
        _showError(error);
      },
      onAutoVerified: (credential) {
        setState(() => _loading = false);
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.manrope()),
      backgroundColor: AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(children: [
          // Bottom orange glow
          Positioned(
            bottom: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),

              // Logo
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('SOKONI',
                    style: GoogleFonts.manrope(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    )),
              ]),

              const SizedBox(height: 52),

              Text('Welcome\nBack 👋',
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
                    height: 1.2,
                    letterSpacing: -1,
                  )),

              const SizedBox(height: 12),

              Text('Enter your phone number to continue',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    color: AppColors.textSub,
                    height: 1.5,
                  )),

              const Spacer(),

              // Phone input
              Text('PHONE NUMBER',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Row(children: [
                  // Country code badge
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('+255',
                        style: GoogleFonts.manrope(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        )),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.manrope(
                        color: AppColors.textWhite, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: '07XX XXX XXX',
                      hintStyle: GoogleFonts.manrope(
                          color: AppColors.textMuted, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  )),
                ]),
              ),

              const SizedBox(height: 24),

              // Send OTP button
              GestureDetector(
                onTap: _loading ? null : _sendOtp,
                child: Container(
                  width: double.infinity,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: _loading ? null : AppColors.primaryGradient,
                    color: _loading ? AppColors.bgCard : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _loading
                        ? []
                        : [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 28,
                                offset: const Offset(0, 10)),
                          ],
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Text('Send OTP',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ]),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                  child: Text(
                'We\'ll send a verification code to your number',
                style: GoogleFonts.manrope(
                    color: AppColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              )),

              const SizedBox(height: 40),
            ]),
          )),
        ]),
      ),
    );
  }
}
