import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Email/Password + Google Sign-In. No billing required (unlike Phone Auth).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Best display name available for the current user:
  /// their set name, else the part of the email before '@', else 'User'.
  static String displayNameFor(User? user) {
    if (user == null) return 'User';
    if ((user.displayName ?? '').trim().isNotEmpty) return user.displayName!.trim();
    final email = user.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return 'User';
  }

  Future<UserCredential> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.reload();
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Returns null if the user cancels the Google chooser.
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Turns Firebase error codes into friendly, user-facing messages.
  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address is not valid';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No account found with that email';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Wrong email or password';
        case 'email-already-in-use':
          return 'An account already exists for that email';
        case 'weak-password':
          return 'Password is too weak (use at least 6 characters)';
        case 'network-request-failed':
          return 'No internet connection. Check your network';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later';
        case 'account-exists-with-different-credential':
          return 'This email is already linked to another sign-in method';
        default:
          return e.message ?? 'Something went wrong, please try again';
      }
    }
    return 'Something went wrong, please try again';
  }
}
