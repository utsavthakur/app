import 'package:flutter/material.dart';
import 'package:aura_app/core/performance/performance_monitor.dart';
import 'package:aura_app/core/error/error_handler.dart';

/// Clean Architecture Dependency Injection Container
class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();
  
  ServiceLocator._() {
    _registerServices();
  }

  // Service registry
  final Map<Type, dynamic> _services = {};
  final Map<String, dynamic> _namedServices = {};

  void _registerServices() {
    // Register core services here
    register<PerformanceMonitor>(PerformanceMonitor.instance);
    register<ErrorHandler>(ErrorHandler.instance);
  }

  /// Register a service by type
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Register a service by name
  void registerNamed<T>(String name, T service) {
    _namedServices[name] = service;
  }

  /// Get a service by type
  T get<T>() {
    return _services[T] as T;
  }

  /// Get a service by name
  T getNamed<T>(String name) {
    return _namedServices[name] as T;
  }

  /// Check if service is registered
  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Clear all services (for testing)
  void clear() {
    _services.clear();
    _namedServices.clear();
  }
}

/// Abstract base service interface
abstract class BaseService {
  void initialize();
  void dispose();
}

/// Mixin for services that need initialization
mixin ServiceMixin {
  bool _initialized = false;

  @mustCallSuper
  void initializeService() {
    if (!_initialized) {
      onInitializeService();
      _initialized = true;
    }
  }

  /// Override this method to implement service-specific initialization
  void onInitializeService();

  @mustCallSuper
  void disposeService() {
    if (_initialized) {
      onDisposeService();
      _initialized = false;
    }
  }

  /// Override this method to implement service-specific disposal
  void onDisposeService();
}

/// Repository pattern for data access
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> clear();
}

/// Use case for business logic
abstract class UseCase<T, Params, Result> {
  Future<Result> execute(Params params);
}

/// Caching mechanism for performance
class Cache<K, V> {
  final Map<K, CacheEntry<V>> _cache = {};
  final int maxSize;
  final Duration ttl;

  Cache({this.maxSize = 100, this.ttl = const Duration(minutes: 5)});

  V? get(K key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired()) {
      return entry.value;
    }
    return null;
  }

  void put(K key, V value) {
    // Remove oldest entries if cache is full
    if (_cache.length >= maxSize) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    _cache[key] = CacheEntry(value, DateTime.now().add(ttl));
  }

  void clear() {
    _cache.clear();
  }

  int get size => _cache.length;
}

class CacheEntry<V> {
  final V value;
  final DateTime expiry;

  CacheEntry(this.value, this.expiry);

  bool isExpired() {
    return DateTime.now().isAfter(expiry);
  }
}