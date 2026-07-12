import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Single source of truth for navigation based on auth state.
/// - Logged in  -> HomeScreen
/// - Logged out -> LoginScreen (also fires automatically after Sign Out)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(gradient: AppColors.bgGradient),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }
        return snap.hasData ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
