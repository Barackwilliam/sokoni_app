import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _authService = AuthService();
  String _otp = '';
  bool _loading = false;

  Future<void> _verify() async {
    if (_otp.length != 6) {
      _showError('Please enter the 6-digit code');
      return;
    }
    setState(() => _loading = true);
    try {
      await _authService.verifyOtp(_otp);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
        (route) => false,
      );
    } catch (e) {
      _showError('Invalid code, please try again');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          Positioned(
            bottom: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.25),
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
              const SizedBox(height: 24),

              // Back button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textWhite, size: 17),
                ),
              ),

              const SizedBox(height: 40),

              Text('Verify\nNumber 🔐',
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textWhite,
                    height: 1.2,
                    letterSpacing: -1,
                  )),

              const SizedBox(height: 12),

              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: 'Code sent to ',
                    style: GoogleFonts.manrope(
                        color: AppColors.textSub, fontSize: 15)),
                TextSpan(
                    text: widget.phoneNumber,
                    style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ])),

              const Spacer(),

              // OTP input
              Text('VERIFICATION CODE',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  )),
              const SizedBox(height: 16),

              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                onChanged: (v) => _otp = v,
                onCompleted: (v) {
                  _otp = v;
                  _verify();
                },
                animationType: AnimationType.scale,
                animationDuration: const Duration(milliseconds: 150),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 54,
                  fieldWidth: 46,
                  activeColor: AppColors.primary,
                  activeFillColor: AppColors.bgCard,
                  selectedColor: AppColors.primary,
                  selectedFillColor: AppColors.bgCard,
                  inactiveColor: AppColors.divider,
                  inactiveFillColor: AppColors.bgCard,
                  borderWidth: 1.5,
                ),
                enableActiveFill: true,
                textStyle: GoogleFonts.manrope(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: AppColors.primary,
              ),

              const SizedBox(height: 28),

              // Verify button
              GestureDetector(
                onTap: _loading ? null : _verify,
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
                      : Text('Verify & Continue',
                          style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                  child: RichText(
                      text: TextSpan(children: [
                TextSpan(
                    text: "Didn't receive code? ",
                    style: GoogleFonts.manrope(
                        color: AppColors.textMuted, fontSize: 13)),
                TextSpan(
                    text: 'Resend',
                    style: GoogleFonts.manrope(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ]))),

              const SizedBox(height: 40),
            ]),
          )),
        ]),
      ),
    );
  }
}
