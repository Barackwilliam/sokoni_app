import 'package:flutter/material.dart';
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
      _showError('Weka namba sahihi ya simu');
      return;
    }

    // Geuza namba ya ndani (07xx...) kuwa international format (+255...)
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
          MaterialPageRoute(builder: (_) => OtpScreen(phoneNumber: phone)),
        );
      },
      onError: (error) {
        setState(() => _loading = false);
        _showError(error);
      },
      onAutoVerified: (credential) {
        setState(() => _loading = false);
        // Android auto-verification - moja kwa moja login
      },
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storefront, size: 60, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Karibu Sokoni',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingiza namba yako ya simu kuendelea',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone),
                  hintText: '07XX XXX XXX',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Pata OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
