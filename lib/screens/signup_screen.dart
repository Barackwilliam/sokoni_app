import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _password.text;
    if (name.isEmpty) {
      _error('Please enter your name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _error('Please enter a valid email address');
      return;
    }
    if (pass.length < 6) {
      _error('Password must be at least 6 characters');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.signUpWithEmail(name: name, email: email, password: pass);
      if (mounted) {
        // Pop back to AuthGate, which now shows HomeScreen.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) _error(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);
    try {
      final cred = await _auth.signInWithGoogle();
      if (cred != null && mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) _error(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _error(String msg) {
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
                  AppColors.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: AppColors.divider, width: 0.5),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textWhite, size: 20),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('Create\nAccount ✨',
                      style: GoogleFonts.manrope(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textWhite,
                        height: 1.2,
                        letterSpacing: -1,
                      )),
                  const SizedBox(height: 12),
                  Text('Join Sokoni and discover local businesses',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: AppColors.textSub,
                        height: 1.5,
                      )),
                  const SizedBox(height: 36),
                  _label('FULL NAME'),
                  const SizedBox(height: 10),
                  _field(
                    controller: _name,
                    hint: 'e.g. Willy Barack',
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 20),
                  _label('EMAIL'),
                  const SizedBox(height: 10),
                  _field(
                    controller: _email,
                    hint: 'you@example.com',
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  _label('PASSWORD'),
                  const SizedBox(height: 10),
                  _field(
                    controller: _password,
                    hint: 'At least 6 characters',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                          size: 20),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _primaryButton(
                    label: 'Create Account',
                    loading: _loading,
                    onTap: _loading ? null : _signUp,
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or',
                          style: GoogleFonts.manrope(
                              color: AppColors.textMuted, fontSize: 13)),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ]),
                  const SizedBox(height: 24),
                  _googleButton(),
                  const SizedBox(height: 28),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Already have an account? ",
                              style: GoogleFonts.manrope(
                                  color: AppColors.textMuted, fontSize: 14)),
                          TextSpan(
                              text: 'Sign In',
                              style: GoogleFonts.manrope(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, color: AppColors.textMuted, size: 20),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style:
                GoogleFonts.manrope(color: AppColors.textWhite, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        if (suffix != null) suffix,
      ]),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: loading ? null : AppColors.primaryGradient,
          color: loading ? AppColors.bgCard : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? []
              : [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 28,
                      offset: const Offset(0, 10)),
                ],
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
            : Text(label,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
      ),
    );
  }

  Widget _googleButton() {
    return GestureDetector(
      onTap: _googleLoading ? null : _google,
      child: Container(
        width: double.infinity,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: _googleLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text('G',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF4285F4),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Text('Continue with Google',
                      style: GoogleFonts.manrope(
                        color: AppColors.textWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
      ),
    );
  }
}
