import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tag_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';

class TagNotifier extends StateNotifier<AsyncValue<List<TagModel>>> {
  final FirestoreService _service;

  TagNotifier(this._service) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _service.streamTags().listen((tags) {
      state = AsyncValue.data(tags);
    }, onError: (e, st) {
      state = AsyncValue.error(e, st);
    });
  }

  Future<void> addTag(String name, String color) async {
    final newTag = TagModel(
      id: '',
      name: name,
      color: color,
    );
    await _service.addTag(newTag);
  }

  Future<void> deleteTag(String id) async {
    await _service.deleteTag(id);
  }
}

final tagNotifierProvider = StateNotifierProvider<TagNotifier, AsyncValue<List<TagModel>>>((ref) {
  return TagNotifier(ref.watch(firestoreServiceProvider));
});
