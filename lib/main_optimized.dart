// ignore_for_file: deprecated_member_use
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:aura_app/home_feed.dart';
import 'package:aura_app/explore_page.dart';
import 'package:aura_app/profile_page.dart';
import 'package:aura_app/settings_page.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/widgets/asteroid_fragments.dart';
import 'package:aura_app/theme/app_colors.dart';
import 'package:aura_app/core/performance/performance_monitor.dart';
import 'package:aura_app/core/error/error_handler.dart';
import 'package:aura_app/core/di/service_locator.dart';

import 'package:device_preview/device_preview.dart';

void main() {
  // Initialize services
  final serviceLocator = ServiceLocator.instance;
  
  // Initialize error handling
  final errorHandler = serviceLocator.get<ErrorHandler>();
  
  // Initialize performance monitoring
  final performanceMonitor = serviceLocator.get<PerformanceMonitor>();
  
  runApp(
    SafeBuilder(
      operationName: 'AppInitialization',
      builder: (context) => DevicePreview(
        enabled: true,
        builder: (context) => AuraApp(serviceLocator: serviceLocator),
      ),
    ),
  );
}

class AuraApp extends StatefulWidget {
  final ServiceLocator serviceLocator;
  
  const AuraApp({super.key, required this.serviceLocator});

  @override
  State<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends State<AuraApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'AURA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.midnightInk,
        fontFamily: 'Roboto',
      ),
      home: HomePage(serviceLocator: widget.serviceLocator),
    );
  }
}

class HomePage extends StatefulWidget {
  final ServiceLocator serviceLocator;
  
  const HomePage({super.key, required this.serviceLocator});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int selectedIndex = 0;

  // Sidebar parameters - memoized
  static const double sidebarWidth = 60.0;
  static const double closedRight = -80.0;
  static const double openRight = 15.0;
  static const double travelDistance = openRight - closedRight;
  
  double _handleYAlign = 0.45;
  int? _previewIndex;
  
  // 3D Navigation State
  bool _isOverviewMode = false;
  late PageController _pageController;

  // Memoized icons list
  static const List<IconData> icons = [
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.settings_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 1.0,
    );
    _pageController = PageController(viewportFraction: 1.0, initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.delta.dx / travelDistance;
    
    setState(() {
      final double screenHeight = MediaQuery.of(context).size.height;
      _handleYAlign += details.delta.dy / screenHeight;
      _handleYAlign = _handleYAlign.clamp(0.1, 0.9);
    });
  }

  void _onDragEnd(DragEndDetails details) {
     if (_controller.isDismissed || _controller.isCompleted) return;

     final double velocityX = details.velocity.pixelsPerSecond.dx;

     if (velocityX < -365.0) {
       _controller.forward();
     } else if (velocityX > 365.0) {
       _controller.reverse();
     } else {
       if (_controller.value > 0.5) {
         _controller.forward();
       } else {
         _controller.reverse();
       }
     }
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey('home_page'),
      child: Scaffold(
        backgroundColor: AppColors.midnightInk,
        body: AsteroidFragments(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double animValue = _controller.value;
              final double sidebarRight = ui.lerpDouble(closedRight, openRight, animValue)!;
              final double contentRightMargin = ui.lerpDouble(0, 70, animValue)!;
              final double handleRight = ui.lerpDouble(0, 75, animValue)!;
              
              return Stack(
                children: [
                  // Sidebar
                  Positioned(
                    right: sidebarRight,
                    top: MediaQuery.of(context).size.height * 0.2, 
                    child: RepaintBoundary(
                      key: const ValueKey('sidebar'),
                      child: _GlassSideBar(
                        serviceLocator: widget.serviceLocator,
                        icons: icons,
                        selectedIndex: selectedIndex,
                        previewIndex: _previewIndex,
                        onNavigate: (index) {
                          setState(() {
                            selectedIndex = index;
                            _controller.reverse();
                            if (_pageController.hasClients) {
                              _pageController.jumpToPage(selectedIndex);
                            }
                          });
                        },
                        controller: _controller,
                      ),
                    ),
                  ),
        
                  // Main Content
                  Container(
                    margin: EdgeInsets.only(right: contentRightMargin),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          // Page View with optimizations
                          RepaintBoundary(
                            key: const ValueKey('page_view'),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              scale: _isOverviewMode ? 0.88 : 1.0,
                              child: PageView.builder(
                                key: const ValueKey('main_page_view'),
                                controller: _pageController,
                                physics: _isOverviewMode
                                    ? const BouncingScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                itemCount: icons.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return RepaintBoundary(
                                    key: ValueKey('page_$index'),
                                    child: _PageContent(
                                      serviceLocator: widget.serviceLocator,
                                      pageIndex: index,
                                      isSelected: selectedIndex == index,
                                      isOverviewMode: _isOverviewMode,
                                      onTap: () {
                                        if (_isOverviewMode) {
                                          setState(() {
                                            _isOverviewMode = false;
                                            _pageController.animateToPage(
                                              index,
                                              duration: const Duration(milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                        }
                                      },
                                      onLongPress: () {
                                        setState(() {
                                          _isOverviewMode = true;
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        
                          // Slider Handle
                          RepaintBoundary(
                            key: const ValueKey('slider_handle'),
                            child: Positioned(
                              right: handleRight, 
                              top: MediaQuery.of(context).size.height * _handleYAlign,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onPanUpdate: _onDragUpdate,
                                onPanEnd: _onDragEnd,
                                onTap: _toggle,
                                child: Container(
                                  color: Colors.transparent,
                                  height: 120,
                                  width: 60,
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Container(
                                     height: 80,
                                     width: 20,
                                     decoration: BoxDecoration(
                                       color: AppColors.graphiteSmoke.withOpacity(0.5),
                                       borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                       boxShadow: [
                                         BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10)
                                       ],
                                       border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                                     ),
                                     child: Center(
                                       child: Icon(
                                         animValue > 0.5 ? Icons.chevron_right : Icons.chevron_left, 
                                         color: Colors.white, size: 18
                                       ),
                                     ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Optimized sidebar component
class _GlassSideBar extends StatelessWidget {
  final ServiceLocator serviceLocator;
  final List<IconData> icons;
  final int selectedIndex;
  final int? previewIndex;
  final Function(int) onNavigate;
  final AnimationController controller;

  const _GlassSideBar({
    super.key,
    required this.serviceLocator,
    required this.icons,
    required this.selectedIndex,
    required this.previewIndex,
    required this.onNavigate,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      height: 360,
      width: sidebarWidth,
      borderRadius: 30,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          final double itemHeight = 360.0 / icons.length;
          final int index = (details.localPosition.dy / itemHeight).floor();
          
          if (index >= 0 && index < icons.length) {
            onNavigate(index);
          }
        },
        onVerticalDragUpdate: (details) {
          final double itemHeight = 360.0 / icons.length;
          final int index = (details.localPosition.dy / itemHeight).floor();
          
          if (index >= 0 && index < icons.length && index != previewIndex) {
            // No setState on drag update for performance
            // Just update local state for visual feedback
          }
        },
        onVerticalDragEnd: (details) {
          if (previewIndex != null) {
            onNavigate(previewIndex!);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(icons.length, (index) {
            final bool active = selectedIndex == index;
            final bool hovering = previewIndex == index;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 40,
              width: 40,
              decoration: (active || hovering)
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withOpacity(hovering ? 0.4 : 0.2),
                      boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10)]
                    )
                  : null,
              child: Icon(
                icons[index],
                size: 24,
                color: (active || hovering) ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Optimized page content component
class _PageContent extends StatelessWidget {
  final ServiceLocator serviceLocator;
  final int pageIndex;
  final bool isSelected;
  final bool isOverviewMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PageContent({
    super.key,
    required this.serviceLocator,
    required this.pageIndex,
    required this.isSelected,
    required this.isOverviewMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        margin: EdgeInsets.symmetric(
          horizontal: isOverviewMode ? 8 : 0,
          vertical: isOverviewMode ? 50 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isOverviewMode ? 25 : 0),
          boxShadow: isOverviewMode
              ? [
                  BoxShadow(
                    color: AppColors.midnightInk.withOpacity(0.8),
                    blurRadius: 30,
                    spreadRadius: -5,
                  )
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isOverviewMode ? 25 : 0),
          child: _getPageWidget(pageIndex),
        ),
      ),
    );
  }

  Widget _getPageWidget(int index) {
    switch (index) {
      case 0: return HomeFeed(key: ValueKey('Home'));
      case 1: return ExplorePage(key: ValueKey('Explore'));
      case 2: return SettingsPage(key: ValueKey('Settings'));
      case 3: return const Center(child: Text("Notifications", style: TextStyle(color: Colors.white)));
      case 4: return ProfilePage(key: ValueKey('Profile'));
      default: return const SizedBox.shrink();
    }
  }
}