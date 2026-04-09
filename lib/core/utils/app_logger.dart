import 'dart:developer' as dev;

/// Centralized application logger.
///
/// Replaces silent `catch (_) {}` blocks with structured diagnostic logging.
/// Uses [dart:developer] so messages appear in DevTools  and can be filtered
/// by zone/name without adding a third-party dependency.
class AppLogger {
  const AppLogger._();

  /// Log an error that was previously swallowed silently.
  ///
  /// [context] should be a short string identifying the call-site, e.g.
  /// `'MemorizationProviders.loadSessions'`.
  static void error(
    String context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    dev.log(
      '[$context] $error',
      name: 'QuranKareem',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // SEVERE
    );
  }

  /// Log a warning (non-critical but noteworthy).
  static void warning(String context, String message) {
    dev.log(
      '[$context] $message',
      name: 'QuranKareem',
      level: 900, // WARNING
    );
  }

  /// Log an informational message.
  static void info(String context, String message) {
    dev.log(
      '[$context] $message',
      name: 'QuranKareem',
      level: 800, // INFO
    );
  }
}
