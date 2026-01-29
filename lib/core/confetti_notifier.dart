import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConfettiType { standard, grand }

class ConfettiRequest {
  final ConfettiType type;
  final DateTime timestamp;

  ConfettiRequest({required this.type, required this.timestamp});
}

class ConfettiNotifier extends StateNotifier<ConfettiRequest?> {
  ConfettiNotifier() : super(null);

  void trigger({ConfettiType type = ConfettiType.standard}) {
    state = ConfettiRequest(type: type, timestamp: DateTime.now());
  }
}

final confettiProvider = StateNotifierProvider<ConfettiNotifier, ConfettiRequest?>((ref) {
  return ConfettiNotifier();
});
