import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  static Quote loading = Quote(text: 'Loading...', author: '');
}

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  List<Quote> _quotes = [];
  Quote? _todaysQuote;
  DateTime? _lastQuoteDate;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Quote? get todaysQuote => _todaysQuote;

  Future<void> loadQuotes() async {
    if (_isLoaded) return;

    try {
      // 1. Try to fetch from Firebase first
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isNotEmpty) {
        _quotes = snapshot.docs.map((doc) {
          final data = doc.data();
          return Quote(
            text: data['text'] ?? '',
            author: data['author'] ?? 'Unknown',
          );
        }).toList();
        _isLoaded = true;
        return;
      }
    } catch (e) {
      print('Firebase quote fetch failed: $e');
    }

    // 2. Fallback to local CSV if Firebase fails or is empty
    try {
      final csvString = await rootBundle.loadString('assets/quotes.csv');
      final lines = csvString.split('\n').where((line) => line.trim().isNotEmpty);

      _quotes = lines.map((line) {
        // More robust CSV parsing: "quote","author" or quote,author
        final regex = RegExp(r'^(?:"?)([^"]*)(?:"?),(?:"?)([^"]*)(?:"?)$');
        final match = regex.firstMatch(line.trim());
        if (match != null) {
          return Quote(
            text: match.group(1) ?? '',
            author: match.group(2) ?? 'Unknown',
          );
        }
        // Simple comma fallback if regex fails
        final parts = line.split(',');
        if (parts.length >= 2) {
          return Quote(
            text: parts[0].replaceAll('"', '').trim(),
            author: parts[1].replaceAll('"', '').trim(),
          );
        }
        return null;
      }).whereType<Quote>().toList();

      if (_quotes.isNotEmpty) {
        _isLoaded = true;
        return;
      }
    } catch (e) {
      print('Local CSV quote load failed: $e');
    }

    // 3. Absolute fallback
    _quotes = [
      Quote(text: 'The journey of a thousand miles begins with one step.', author: 'Lao Tzu'),
      Quote(text: 'Knowing yourself is the beginning of all wisdom.', author: 'Aristotle'),
      Quote(text: 'What we think, we become.', author: 'Buddha'),
    ];
    _isLoaded = true;
  }

  Quote getRandomQuote() {
    if (!_isLoaded || _quotes.isEmpty) {
      return Quote.loading;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Return the same quote for the whole day
    if (_todaysQuote != null && _lastQuoteDate == today) {
      return _todaysQuote!;
    }

    // Seed Random with the date so every user gets the same quote each day
    final dateSeed = today.year * 10000 + today.month * 100 + today.day;
    final random = Random(dateSeed);
    _todaysQuote = _quotes[random.nextInt(_quotes.length)];
    _lastQuoteDate = today;

    return _todaysQuote!;
  }

  Quote forceNewQuote() {
    if (!_isLoaded || _quotes.isEmpty) {
      return Quote.loading;
    }

    if (_quotes.length <= 1) return _quotes.first;

    Quote newQuote;
    do {
      newQuote = _quotes[Random().nextInt(_quotes.length)];
    } while (newQuote.text == _todaysQuote?.text);

    _todaysQuote = newQuote;
    return _todaysQuote!;
  }
}
