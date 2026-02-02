import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends Notifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  @override
  bool build() {
    _init();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return true; // Default to online until check completes
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateState(result);
    
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    state = !results.contains(ConnectivityResult.none);
  }
}

final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() {
  return ConnectivityNotifier();
});
