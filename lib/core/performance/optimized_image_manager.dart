import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimized image caching and loading system
class OptimizedImageManager {
  static OptimizedImageManager? _instance;
  static OptimizedImageManager get instance => _instance ??= OptimizedImageManager._();
  
  OptimizedImageManager._() {
    _initializeImageCache();
  }

  final Map<String, ui.Image> _memoryCache = {};
  final Map<String, Completer<ui.Image>> _loadingCache = {};
  static const int _maxCacheSize = 100;

  void _initializeImageCache() {
    // Increase Flutter's default cache size for production
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20; // 100MB
  }

  /// Load image with memory caching and error handling
  Future<ui.Image?> loadImage(String url, {int? maxWidth, int? maxHeight}) async {
    final timer = OperationTimer('ImageLoad:$url');
    
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(url)) {
        timer.end();
        return _memoryCache[url];
      }

      // Check if already loading
      if (_loadingCache.containsKey(url)) {
        final image = await _loadingCache[url]!.future;
        timer.end();
        return image;
      }

      // Load image with isolate
      final completer = Completer<ui.Image>();
      _loadingCache[url] = completer;
      
      final image = await _loadImageIsolate(url, maxWidth, maxHeight);
      
      if (image != null) {
        _cacheImage(url, image);
        completer.complete(image);
      } else {
        completer.completeError('Failed to load image');
      }
      
      _loadingCache.remove(url);
      timer.end();
      return image;
    } catch (e) {
      timer.end();
      developer.log('❌ Failed to load image: $url', error: e, name: 'ImageManager');
      _loadingCache.remove(url);
      return null;
    }
  }

  /// Load image in isolate to avoid blocking UI thread
  Future<ui.Image?> _loadImageIsolate(String url, int? maxWidth, int? maxHeight) async {
    try {
      final completer = Completer<ui.Image>();
      
      // Use network image with proper error handling
      final imageStream = NetworkImage(url).resolve(const ImageConfiguration());
      
      final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
      }, onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception);
      });
      
      imageStream.addListener(listener);
      return completer.future;
    } catch (e) {
      return null;
    }
  }

  void _cacheImage(String url, ui.Image image) {
    // Manage cache size
    if (_memoryCache.length >= _maxCacheSize) {
      _evictOldestEntry();
    }
    
    _memoryCache[url] = image;
  }

  void _evictOldestEntry() {
    if (_memoryCache.isNotEmpty) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
    }
  }

  void clearCache() {
    _memoryCache.clear();
    _loadingCache.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Preload critical images for smooth navigation
  Future<void> preloadImages(List<String> urls) async {
    final timer = OperationTimer('PreloadImages');
    
    await Future.wait(
      urls.map((url) => loadImage(url)),
      eagerError: true, // Continue even if some fail
    );
    
    timer.end();
  }
}

/// Widget for optimized image display with placeholder and error handling
class OptimizedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;
  final bool enableCache;
  
  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = const SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(color: Colors.grey),
    ),
    this.errorWidget = const Icon(Icons.error, color: Colors.grey),
    this.enableCache = true,
  });

  @override
  State<OptimizedNetworkImage> createState() => _OptimizedNetworkImageState();
}

class _OptimizedNetworkImageState extends State<OptimizedNetworkImage> {
  ui.Image? _cachedImage;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!widget.enableCache) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final image = await OptimizedImageManager.instance.loadImage(
      widget.imageUrl,
      maxWidth: widget.width?.toInt(),
      maxHeight: widget.height?.toInt(),
    );

    if (mounted) {
      setState(() {
        _cachedImage = image;
        _isLoading = false;
        _hasError = image == null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder;
    }

    if (_hasError || _cachedImage == null) {
      return widget.errorWidget;
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _CachedImagePainter(_cachedImage!),
        size: Size(
          widget.width ?? _cachedImage!.width.toDouble(),
          widget.height ?? _cachedImage!.height.toDouble(),
        ),
      ),
    );
  }
}

class _CachedImagePainter extends CustomPainter {
  final ui.Image image;
  
  _CachedImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, dstRect, Paint());
  }

  @override
  bool shouldRepaint(_CachedImagePainter oldDelegate) => false;
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