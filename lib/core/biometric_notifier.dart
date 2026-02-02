import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricState {
  final bool isEnabled;
  final bool isAutoLockEnabled;
  final bool isLocked;
  final bool canCheckBiometrics;

  const BiometricState({
    this.isEnabled = false,
    this.isAutoLockEnabled = false,
    this.isLocked = false,
    this.canCheckBiometrics = false,
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

class BiometricNotifier extends Notifier<BiometricState> {
  final LocalAuthentication _auth = LocalAuthentication();
  static const _prefKeyEnabled = 'biometricEnabled';
  static const _prefKeyAutoLock = 'biometricAutoLock';

  @override
  BiometricState build() {
    _init();
    return const BiometricState();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_prefKeyEnabled) ?? false;
    final autoLock = prefs.getBool(_prefKeyAutoLock) ?? false;
    final canCheck = await _auth.canCheckBiometrics;

    state = state.copyWith(
      isEnabled: enabled,
      isAutoLockEnabled: autoLock,
      canCheckBiometrics: canCheck,
      isLocked: enabled && autoLock,
    );
  }

  Future<void> setEnabled(bool enable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyEnabled, enable);
    state = state.copyWith(isEnabled: enable);
    if (!enable) {
      state = state.copyWith(isLocked: false);
    }
  }

  Future<bool> toggleBiometric(bool enable) async {
    if (enable) {
      // Must authenticate first before enabling
      final authenticated = await authenticate();
      if (authenticated) {
        await setEnabled(true);
        return true;
      }
      return false;
    } else {
      await setEnabled(false);
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
      // local_auth 3.x: AuthenticationOptions replaced with direct parameters
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock FlowLife',
        // stickyAuth -> persistAcrossBackgrounding in v3.0.0
        // biometricOnly is removed in v3.0.0; use default behavior
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

  void checkAutoLock() {
    if (state.isEnabled && state.isAutoLockEnabled) {
      state = state.copyWith(isLocked: true);
    }
  }
}

final biometricProvider =
    NotifierProvider<BiometricNotifier, BiometricState>(() {
  return BiometricNotifier();
});
