import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkSelectionState {
  final bool isSelectionMode;
  final Set<String> selectedTaskIds;

  BulkSelectionState({
    required this.isSelectionMode,
    required this.selectedTaskIds,
  });

  BulkSelectionState copyWith({
    bool? isSelectionMode,
    Set<String>? selectedTaskIds,
  }) {
    return BulkSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedTaskIds: selectedTaskIds ?? this.selectedTaskIds,
    );
  }
}

class BulkSelectionNotifier extends Notifier<BulkSelectionState> {
  @override
  BulkSelectionState build() {
    return BulkSelectionState(isSelectionMode: false, selectedTaskIds: {});
  }

  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedTaskIds: {},
    );
  }

  void selectTask(String taskId) {
    final updatedIds = Set<String>.from(state.selectedTaskIds);
    if (updatedIds.contains(taskId)) {
      updatedIds.remove(taskId);
    } else {
      updatedIds.add(taskId);
    }
    state = state.copyWith(selectedTaskIds: updatedIds);
  }

  void clearSelection() {
    state = state.copyWith(selectedTaskIds: {});
  }
}

final bulkSelectionProvider =
    NotifierProvider<BulkSelectionNotifier, BulkSelectionState>(() {
  return BulkSelectionNotifier();
});
