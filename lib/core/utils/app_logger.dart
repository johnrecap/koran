import 'dart:async';
import 'dart:developer' as dev;

import 'package:quran_kareem/core/services/error_reporting_service.dart';

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
    _logError(
      context,
      error,
      stackTrace,
      fatal: false,
    );
  }

  static void fatal(
    String context,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    _logError(
      context,
      error,
      stackTrace,
      fatal: true,
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

  static void _logError(
    String context,
    Object error,
    StackTrace? stackTrace, {
    required bool fatal,
  }) {
    dev.log(
      '[$context] $error',
      name: 'QuranKareem',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // SEVERE
    );
    unawaited(
      ErrorReporting.report(
        ErrorReport(
          context: context,
          error: error,
          stackTrace: stackTrace,
          fatal: fatal,
        ),
      ),
    );
  }
}
