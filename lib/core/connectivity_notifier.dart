import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityNotifier extends StateNotifier<bool> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  ConnectivityNotifier() : super(true) {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateState(result);
    
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    // We consider it "online" if there's any connection other than none
    state = !results.contains(ConnectivityResult.none);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});
