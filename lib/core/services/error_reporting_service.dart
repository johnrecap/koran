import 'dart:async';
import 'dart:developer' as dev;

class ErrorReport {
  const ErrorReport({
    required this.context,
    required this.error,
    this.stackTrace,
    this.fatal = false,
  });

  final String context;
  final Object error;
  final StackTrace? stackTrace;
  final bool fatal;
}

abstract class ErrorReportingService {
  FutureOr<void> reportError(ErrorReport report);
}

class NoopErrorReportingService implements ErrorReportingService {
  const NoopErrorReportingService();

  @override
  void reportError(ErrorReport report) {}
}

abstract final class ErrorReporting {
  static ErrorReportingService _service = const NoopErrorReportingService();

  static ErrorReportingService get service => _service;

  static void install(ErrorReportingService service) {
    _service = service;
  }

  static void reset() {
    _service = const NoopErrorReportingService();
  }

  static Future<void> report(ErrorReport report) async {
    try {
      await Future.sync(() => _service.reportError(report));
    } catch (error, stackTrace) {
      dev.log(
        '[ErrorReporting.report] $error',
        name: 'QuranKareem',
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }
}
