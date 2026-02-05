import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/firestore_service.dart';
import '../data/models/models.dart';
import 'quote_service.dart';

import 'auth_notifier.dart';

final firestoreServiceProvider = Provider((ref) {
  // We watch authProvider to ensure this provider is recreated when user changes
  ref.watch(authProvider);
  return FirestoreService();
});

final projectsProvider = StreamProvider<List<ProjectModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamProjects();
});

final tasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamTasks();
});

final ideasProvider = StreamProvider<List<IdeaModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.streamIdeas();
});

// Riverpod 3.x: StateProvider moved to Notifier pattern
class SelectedProjectFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setProject(String? projectId) => state = projectId;
  void clear() => state = null;
}


final selectedProjectFilterProvider = NotifierProvider<SelectedProjectFilterNotifier, String?>(() {
  return SelectedProjectFilterNotifier();
});

class QuoteNotifier extends Notifier<Quote> {
  final _service = QuoteService();

  @override
  Quote build() {
    _init();
    return _service.todaysQuote ?? Quote.loading;
  }

  Future<void> _init() async {
    await _service.loadQuotes();
    state = _service.getRandomQuote();
  }

  void refresh() {
    state = _service.forceNewQuote();
  }
}

final quoteProvider = NotifierProvider<QuoteNotifier, Quote>(() {
  return QuoteNotifier();
});
