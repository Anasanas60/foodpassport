/// This file provides structured logging for the FoodPassport app.
/// It uses the logging package to capture and format log messages with timestamps, levels, and context.
///
/// Usage:
/// - Import this file: import 'utils/logger.dart';
/// - Use the logger instance: logger.info('Message'), logger.warning('Warning'), logger.severe('Error');
/// - Call setupLogging() in main.dart to initialize logging.
///
/// Log levels:
/// - finest: Finest-grained events (most verbose)
/// - finer: Finer-grained events
/// - fine: Fine-grained events
/// - config: Configuration messages
/// - info: Informational messages (default for general info)
/// - warning: Warning messages
/// - severe: Severe errors (equivalent to error)
/// - shout: Shout messages (most critical)
///
/// Example:
/// logger.info('Starting food recognition...');
/// logger.severe('API call failed', error: e, stackTrace: stackTrace);

import 'package:logging/logging.dart';

final Logger logger = Logger('FoodPassportApp');

void setupLogging() {
  Logger.root.level = Level.ALL; // Capture all log levels
  Logger.root.onRecord.listen((record) {
    final time = record.time.toIso8601String();
    print('[${record.level.name}] $time: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
  });
}
