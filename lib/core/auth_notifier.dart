import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthNotifier extends Notifier<User?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? build() {
    _init();
    return _auth.currentUser;
  }

  void _init() async {
    // google_sign_in 7.x: Initialize the singleton instance first
    await GoogleSignIn.instance.initialize();
    
    // Set up auth state listening
    _auth.authStateChanges().listen((user) async {
      state = user;
      
      // If no firebase user, try lightweight (silent) authentication
      if (user == null) {
        try {
          // Try lightweight/silent authentication
          final result = await GoogleSignIn.instance.attemptLightweightAuthentication();
          if (result != null) {
            // User is authenticated, get authorization for Firebase
            final authorization = await result.authorizationClient.authorizationForScopes(['email']);
            if (authorization != null) {
              final credential = GoogleAuthProvider.credential(
                accessToken: authorization.accessToken,
              );
              await _auth.signInWithCredential(credential);
            }
          }
        } catch (e) {
          debugPrint('Silent sign-in failed: $e');
        }
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      // google_sign_in 7.x: Use authenticate() for interactive sign-in
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        final result = await GoogleSignIn.instance.authenticate();
        if (result == null) return;

        // Get authorization with access token
        final authorization = await result.authorizationClient.authorizeScopes(['email']);
        if (authorization == null) return;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authorization.accessToken,
        );

        await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}

final authProvider = NotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});
