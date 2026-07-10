import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _ctrl, _glowCtrl;
  late Animation<double> _logoFade, _logoScale, _textFade, _textY, _tagFade, _btnFade, _btnY, _glowPulse;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
    _logoFade  = _i(0.0,  0.25, 0.0, 1.0);
    _logoScale = _i(0.0,  0.35, 0.7, 1.0, curve: Curves.easeOutBack);
    _textFade  = _i(0.25, 0.55, 0.0, 1.0);
    _textY     = _i(0.25, 0.55, 24.0, 0.0);
    _tagFade   = _i(0.45, 0.70, 0.0, 1.0);
    _btnFade   = _i(0.65, 1.0,  0.0, 1.0);
    _btnY      = _i(0.65, 1.0,  30.0, 0.0);
  }

  Animation<double> _i(double s, double e, double from, double to, {Curve curve = Curves.easeOut}) =>
      Tween<double>(begin: from, end: to).animate(CurvedAnimation(parent: _ctrl, curve: Interval(s, e, curve: curve)));

  @override
  void dispose() { _ctrl.dispose(); _glowCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(children: [
          // Warm orange glow bottom
          Positioned(
            bottom: -80, left: size.width * 0.1, right: size.width * 0.1,
            child: AnimatedBuilder(animation: _glowPulse, builder: (_, __) => Container(
              height: 320,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [
                AppColors.primary.withOpacity(_glowPulse.value * 0.45),
                Colors.transparent,
              ])),
            )),
          ),
          // Top-right subtle gold glow
          Positioned(top: -60, right: -60, child: AnimatedBuilder(animation: _glowPulse, builder: (_, __) => Container(
            width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [
              const Color(0xFFF7941D).withOpacity(_glowPulse.value * 0.12),
              Colors.transparent,
            ])),
          ))),

          SafeArea(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 48),

              // Logo
              AnimatedBuilder(animation: _ctrl, builder: (_, __) => Opacity(
                opacity: _logoFade.value,
                child: Transform.scale(scale: _logoScale.value, alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 22, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text('SOKONI', style: GoogleFonts.manrope(
                      color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 3,
                    )),
                  ]),
                ),
              )),

              const SizedBox(height: 56),

              // Hero text
              AnimatedBuilder(animation: _ctrl, builder: (_, __) => Opacity(
                opacity: _textFade.value,
                child: Transform.translate(offset: Offset(0, _textY.value), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discover', style: GoogleFonts.manrope(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.textWhite, height: 1.15, letterSpacing: -1)),
                    Text('Local', style: GoogleFonts.manrope(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.15, letterSpacing: -1)),
                    Text('Businesses\nNear You.', style: GoogleFonts.manrope(fontSize: 38, fontWeight: FontWeight.w800, color: AppColors.textWhite, height: 1.15, letterSpacing: -1)),
                  ],
                )),
              )),

              const SizedBox(height: 20),

              AnimatedBuilder(animation: _ctrl, builder: (_, __) => Opacity(
                opacity: _tagFade.value,
                child: Text('Find artisans, shops, beauty salons\nand restaurants — all in one place.',
                  style: GoogleFonts.manrope(fontSize: 15, color: AppColors.textSub, height: 1.65)),
              )),

              const Spacer(),

              AnimatedBuilder(animation: _ctrl, builder: (_, __) => Opacity(
                opacity: _btnFade.value,
                child: Transform.translate(offset: Offset(0, _btnY.value), child: Column(children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                    )),
                    child: Container(
                      width: double.infinity, height: 58,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 28, offset: const Offset(0, 10))],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Get Started', style: GoogleFonts.manrope(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('by JamiiTek', style: GoogleFonts.manrope(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1.5)),
                ])),
              )),
              const SizedBox(height: 40),
            ]),
          )),
        ]),
      ),
    );
  }
}
