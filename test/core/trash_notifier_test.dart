import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flowlife_mobile/core/trash_notifier.dart';
import 'package:flowlife_mobile/data/services/trash_service.dart';
import 'package:flowlife_mobile/data/models/models.dart';

class ManualMockTrashService implements TrashService {
  TaskModel? trashedTask;
  String? restoredTaskId;
  int? purgeDays;

  @override
  Future<void> trashTask(TaskModel task) async {
    trashedTask = task;
  }

  @override
  Future<void> restoreTask(String taskId) async {
    restoredTaskId = taskId;
  }

  @override
  Future<void> purgeExpiredItems(int days) async {
    purgeDays = days;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ManualMockTrashService mockService;
  late ProviderContainer container;

  setUp(() {
    mockService = ManualMockTrashService();
    container = ProviderContainer(
      overrides: [
        trashServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('trashTask calls service with correct task', () async {
    final task = TaskModel(id: '1', title: 'Test Task', createdAt: 0, completed: false, subtasks: []);
    await container.read(trashNotifierProvider.notifier).trashTask(task);
    expect(mockService.trashedTask?.id, '1');
  });

  test('restoreTask calls service with correct id', () async {
    await container.read(trashNotifierProvider.notifier).restoreTask('1');
    expect(mockService.restoredTaskId, '1');
  });

  test('emptyTrash calls purge with 0 days', () async {
    await container.read(trashNotifierProvider.notifier).emptyTrash();
    expect(mockService.purgeDays, 0);
  });
}
