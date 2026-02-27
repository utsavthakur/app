import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handling and crash reporting system
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  
  ErrorHandler._() {
    _setupGlobalErrorHandling();
  }

  void _setupGlobalErrorHandling() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logError('FlutterError', details.exception, details.stack);
      
      // In production, send to crash reporting service
      if (kReleaseMode) {
        _reportCrashToService(details.exception, details.stack);
      }
    };

    // Platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('PlatformError', error, stack);
      
      if (kReleaseMode) {
        _reportCrashToService(error, stack);
      }
      return true;
    };
  }

  void _logError(String type, dynamic error, StackTrace? stack) {
    if (!kReleaseMode) {
      developer.log(
        '🚨 $type: $error',
        name: 'ErrorHandler',
        error: error,
        stackTrace: stack,
      );
    }
  }

  void _reportCrashToService(dynamic error, StackTrace? stack) {
    // Integration with crash reporting services like Firebase Crashlytics
    // This would be implemented based on your crash reporting service
    try {
      developer.log('Crash reported to service', name: 'ErrorHandler');
    } catch (e) {
      developer.log('Failed to report crash: $e', name: 'ErrorHandler');
    }
  }

  /// Handle async errors gracefully
  Future<T> guardAsync<T>(
    String operation,
    Future<T> Function() asyncOperation, {
    T? fallback,
  }) async {
    final timer = OperationTimer('GuardedOperation:$operation');
    
    try {
      final result = await asyncOperation();
      timer.end();
      return result;
    } catch (error, stack) {
      timer.end();
      _logError('AsyncError:$operation', error, stack);
      
      return fallback ?? (null as T);
    }
  }

  /// Handle sync errors gracefully
  T guardSync<T>(
    String operation,
    T Function() syncOperation, {
    T? fallback,
  }) {
    final timer = OperationTimer('GuardedOperation:$operation');
    
    try {
      final result = syncOperation();
      timer.end();
      return result;
    } catch (error, stack) {
      timer.end();
      _logError('SyncError:$operation', error, stack);
      
      return fallback ?? (null as T);
    }
  }
}

/// Enhanced widget with built-in error handling
class SafeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? errorBuilder;
  final String? operationName;
  
  const SafeBuilder({
    super.key,
    required this.builder,
    this.errorBuilder,
    this.operationName,
  });

  @override
  State<SafeBuilder> createState() => _SafeBuilderState();
}

class _SafeBuilderState extends State<SafeBuilder> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!;
    }
    
    try {
      return widget.builder(context);
    } catch (error, stack) {
      ErrorHandler.instance._logError('BuildError', error, stack);
      
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!;
      }
      
      // Fallback error UI
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Something went wrong',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
  }
}

/// Operation timer for performance tracking
class OperationTimer {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  
  OperationTimer(this.operation) {
    _stopwatch.start();
  }
  
  void end() {
    _stopwatch.stop();
    final ms = _stopwatch.elapsedMilliseconds;
    
    if (ms > 100) {
      developer.log(
        '⚠️ Slow operation: $operation took ${ms}ms',
        name: 'Performance',
        level: ms > 500 ? 1000 : 900,
      );
    }
  }
}