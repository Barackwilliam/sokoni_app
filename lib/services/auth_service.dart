import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? _verificationId;
  int? _resendToken;

  /// Sends (or re-sends) an OTP to [phoneNumber].
  /// Pass [isResend] = true to force a new SMS using the resend token.
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onError,
    required Function(PhoneAuthCredential credential) onAutoVerified,
    bool isResend = false,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: isResend ? _resendToken : null,
      verificationCompleted: (PhoneAuthCredential credential) {
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_friendlyError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw FirebaseAuthException(
          code: 'no-verification-id', message: 'Please request OTP first');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Used when Android auto-retrieves the SMS code (instant verification).
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async => await _auth.signOut();

  static String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'That phone number is not valid. Use format 07XX XXX XXX';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a while and try again';
      case 'network-request-failed':
        return 'No internet connection. Check your network and retry';
      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later';
      default:
        return e.message ?? 'Failed to send OTP, please try again';
    }
  }
}
