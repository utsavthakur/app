import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Production-grade performance monitoring and logging system
class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  
  PerformanceMonitor._() {
    if (!kReleaseMode) {
      _initDebugMonitoring();
    }
  }

  // Performance metrics tracking
  final Map<String, List<int>> _frameMetrics = {};
  final Map<String, DateTime> _startTimes = {};
  final Map<String, int> _memorySnapshots = {};
  Timer? _metricsTimer;

  void _initDebugMonitoring() {
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _collectMetrics();
    });
  }

  /// Simple device performance detection
  bool _isHighEndDevice() {
    // Simple heuristic: assume high-end if not in release mode
    // In production, you'd use device capabilities
    return true; // For now, assume all devices can handle animations
  }

  /// Start timing an operation
  void startOperation(String operation) {
    _startTimes[operation] = DateTime.now();
    if (!kReleaseMode) {
      developer.log('⏱️ Started: $operation', name: 'Performance');
    }
  }

  /// End timing an operation and log duration
  void endOperation(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _recordMetric(operation, duration.inMilliseconds);
      
      if (!kReleaseMode) {
        developer.log(
          '✅ Completed: $operation in ${duration.inMilliseconds}ms',
          name: 'Performance'
        );
      }
      
      // Performance warnings
      if (duration.inMilliseconds > 100) {
        developer.log(
          '🚨 SLOW OPERATION: $operation took ${duration.inMilliseconds}ms',
          name: 'Performance',
          level: duration.inMilliseconds > 500 ? 1000 : 900,
        );
      }
      
      _startTimes.remove(operation);
    }
  }

  /// Record a performance metric
  void _recordMetric(String operation, int milliseconds) {
    _frameMetrics.putIfAbsent(operation, () => []).add(milliseconds);
    
    // Keep only last 100 measurements
    if (_frameMetrics[operation]!.length > 100) {
      _frameMetrics[operation]!.removeAt(0);
    }
  }

  /// Collect system metrics
  void _collectMetrics() {
    // This would integrate with platform-specific APIs in production
    if (!kReleaseMode) {
      developer.log('📊 Performance Metrics:', name: 'Performance');
      for (final entry in _frameMetrics.entries) {
        final metrics = entry.value;
        if (metrics.isNotEmpty) {
          final avg = metrics.reduce((a, b) => a + b) / metrics.length;
          final max = metrics.reduce((a, b) => a > b ? a : b);
          developer.log(
            '  ${entry.key}: avg ${avg.toStringAsFixed(1)}ms, max ${max}ms',
            name: 'Performance'
          );
        }
      }
    }
  }

  /// Widget rebuild counter (for development)
  void logRebuild(String widgetName) {
    if (!kReleaseMode) {
      developer.log('🔄 Rebuild: $widgetName', name: 'Performance');
    }
  }

  /// Memory usage tracking
  void trackMemory(String context) {
    // Placeholder for actual memory tracking
    if (!kReleaseMode) {
      developer.log('💾 Memory check: $context', name: 'Performance');
    }
  }

  void dispose() {
    _metricsTimer?.cancel();
  }
}

/// Performance-optimized widget that tracks rebuilds
class PerformanceAwareWidget extends StatelessWidget {
  final Widget child;
  final String widgetName;
  
  const PerformanceAwareWidget({
    super.key,
    required this.child,
    required this.widgetName,
  });

  @override
  Widget build(BuildContext context) {
    PerformanceMonitor.instance.logRebuild(widgetName);
    return child;
  }
}

/// Operation timer utility for easy measurement
class OperationTimer {
  final String operation;
  final Stopwatch _stopwatch = Stopwatch();
  
  OperationTimer(this.operation) {
    PerformanceMonitor.instance.startOperation(operation);
    _stopwatch.start();
  }
  
  void end() {
    _stopwatch.stop();
    PerformanceMonitor.instance.endOperation(operation);
  }
}