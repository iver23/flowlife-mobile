import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricState {
  final bool isEnabled;
  final bool isAutoLockEnabled;
  final bool isLocked;
  final bool canCheckBiometrics;

  BiometricState({
    required this.isEnabled,
    required this.isAutoLockEnabled,
    required this.isLocked,
    required this.canCheckBiometrics,
  });

  BiometricState copyWith({
    bool? isEnabled,
    bool? isAutoLockEnabled,
    bool? isLocked,
    bool? canCheckBiometrics,
  }) {
    return BiometricState(
      isEnabled: isEnabled ?? this.isEnabled,
      isAutoLockEnabled: isAutoLockEnabled ?? this.isAutoLockEnabled,
      isLocked: isLocked ?? this.isLocked,
      canCheckBiometrics: canCheckBiometrics ?? this.canCheckBiometrics,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _prefKeyEnabled = 'biometric_enabled';
  static const _prefKeyAutoLock = 'biometric_autolock';

  BiometricNotifier() : super(BiometricState(
    isEnabled: false,
    isAutoLockEnabled: true,
    isLocked: false,
    canCheckBiometrics: false,
  )) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_prefKeyEnabled) ?? false;
    final isAutoLock = prefs.getBool(_prefKeyAutoLock) ?? true;
    final canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

    state = state.copyWith(
      isEnabled: isEnabled,
      isAutoLockEnabled: isAutoLock,
      isLocked: isEnabled, // Start locked if enabled
      canCheckBiometrics: canCheck,
    );
  }

  Future<bool> toggleBiometric(bool enable) async {
    if (enable) {
      final success = await authenticate();
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyEnabled, true);
        state = state.copyWith(isEnabled: true, isLocked: false);
        return true;
      }
      return false;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyEnabled, false);
      state = state.copyWith(isEnabled: false, isLocked: false);
      return true;
    }
  }

  Future<void> setAutoLock(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyAutoLock, enable);
    state = state.copyWith(isAutoLockEnabled: enable);
  }

  Future<bool> authenticate() async {
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock FlowLife',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Fallback to PIN/Pattern if biometric fails
        ),
      );
      if (isAuthenticated) {
        state = state.copyWith(isLocked: false);
      }
      return isAuthenticated;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }

  void lock() {
    if (state.isEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    state = state.copyWith(isLocked: false);
  }
}

final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  return BiometricNotifier();
});
