import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppLogger {
  static void auth(String message) => _log('AUTH', message);
  static void sync(String message) => _log('SYNC', message);
  static void migration(String message) => _log('MIGRATION', message);
  static void notification(String message) => _log('NOTIFICATION', message);
  static void error(String message, [dynamic error, StackTrace? stack]) {
    debugPrint('[ERROR] $message: $error');
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(error, stack, reason: message);
    } else {
      FirebaseCrashlytics.instance.log('[ERROR] $message');
    }
  }
  
  static void _log(String channel, String message) {
    debugPrint('[$channel] $message');
    FirebaseCrashlytics.instance.log('[$channel] $message');
  }
}
