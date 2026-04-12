import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/core/services/error_reporting_service.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';

void main() {
  tearDown(ErrorReporting.reset);

  test('AppLogger.error forwards non-fatal reports to the installed reporter',
      () async {
    final reporter = _FakeErrorReportingService();
    final error = StateError('boom');
    final stackTrace = StackTrace.current;

    ErrorReporting.install(reporter);

    AppLogger.error('test.error', error, stackTrace);
    await pumpEventQueue();

    expect(reporter.reports, hasLength(1));
    final report = reporter.reports.single;
    expect(report.context, 'test.error');
    expect(report.error, same(error));
    expect(report.stackTrace, same(stackTrace));
    expect(report.fatal, isFalse);
  });

  test('AppLogger.fatal forwards fatal reports to the installed reporter',
      () async {
    final reporter = _FakeErrorReportingService();
    final error = StateError('fatal');
    final stackTrace = StackTrace.current;

    ErrorReporting.install(reporter);

    AppLogger.fatal('test.fatal', error, stackTrace);
    await pumpEventQueue();

    expect(reporter.reports, hasLength(1));
    expect(reporter.reports.single.context, 'test.fatal');
    expect(reporter.reports.single.error, same(error));
    expect(reporter.reports.single.stackTrace, same(stackTrace));
    expect(reporter.reports.single.fatal, isTrue);
  });
}

class _FakeErrorReportingService implements ErrorReportingService {
  final List<ErrorReport> reports = <ErrorReport>[];

  @override
  Future<void> reportError(ErrorReport report) async {
    reports.add(report);
  }
}
