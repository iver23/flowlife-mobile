import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthNotifier() : super(null) {
    _init();
  }

  void _init() async {
    // 1. Listen to Firebase Auth changes
    _auth.authStateChanges().listen((user) async {
      state = user;
      
      // If no firebase user, try silent google sign in to recover session if possible
      if (user == null) {
        try {
          final silentUser = await _googleSignIn.signInSilently();
          if (silentUser != null) {
            final auth = await silentUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: auth.accessToken,
              idToken: auth.idToken,
            );
            await _auth.signInWithCredential(credential);
          }
        } catch (_) {}
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect(); // This forces account picker next time
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});
