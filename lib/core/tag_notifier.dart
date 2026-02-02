import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/tag_model.dart';
import '../data/services/firestore_service.dart';
import 'providers.dart';

class TagNotifier extends AsyncNotifier<List<TagModel>> {
  FirestoreService get _service => ref.read(firestoreServiceProvider);

  @override
  FutureOr<List<TagModel>> build() async {
    final stream = _service.streamTags();
    
    stream.listen((tags) {
      state = AsyncData(tags);
    }, onError: (e, st) {
      state = AsyncError(e, st);
    });

    return stream.first;
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

final tagNotifierProvider = AsyncNotifierProvider<TagNotifier, List<TagModel>>(() {
  return TagNotifier();
});
