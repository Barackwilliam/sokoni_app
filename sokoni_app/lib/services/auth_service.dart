import 'package:firebase_auth/firebase_auth.dart';

/// Inashughulikia login kwa namba ya simu + OTP kupitia Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? _verificationId;

  /// Hatua 1: Tuma OTP kwenye namba aliyoingiza
  /// [phoneNumber] lazima iwe na country code, mfano: +255712345678
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        // Android pekee: wakati mwingine OTP inajazwa automatic
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Imeshindikana kutuma OTP, jaribu tena');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Hatua 2: Thibitisha OTP aliyoiweka user
  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('Verification ID haipo, tuma OTP kwanza');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
