// ignore_for_file: deprecated_member_use
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:aura_app/home_feed.dart';
import 'package:aura_app/explore_page.dart';
import 'package:aura_app/profile_page.dart';
import 'package:aura_app/settings_page.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';
import 'package:aura_app/core/performance/performance_monitor.dart';
import 'package:aura_app/core/error/error_handler.dart';
import 'package:aura_app/login_page.dart';
import 'package:aura_app/services/api_service.dart';

import 'package:device_preview/device_preview.dart';

void main() {
  // Initialize performance monitoring
  PerformanceMonitor.instance;
  
  // Initialize error handling
  ErrorHandler.instance;
  
  runApp(
    SafeBuilder(
      operationName: 'AppInitialization',
      builder: (context) => DevicePreview(
        enabled: true,
        builder: (context) => const AuraApp(),
      ),
    ),
  );
}

class AuraApp extends StatefulWidget {
  const AuraApp({super.key});

  @override
  State<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends State<AuraApp> {
  Widget? _defaultHome;
  
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final isLoggedIn = await ApiService().isLoggedIn();
    setState(() {
      _defaultHome = isLoggedIn ? const HomePage() : const LoginPage();
    });
  }

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
      home: _defaultHome ?? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.sunsetCoral),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  int selectedIndex = 0;

  // Sidebar parameters
  static const double _sidebarHeight = 420.0;
  static const double _sidebarWidth = 60.0;
  static const double _closedRight = -80.0;
  static const double _openRight = 15.0;
  static const double _travelDistance = _openRight - _closedRight; // 95.0
  
  double _handleYAlign = 0.5; // Center the handle
  int? _previewIndex; // For slide-to-select feedback
  bool _isMovingSidebar = false; // Mode for moving the sidebar vertically

  double _sidebarAlign = 1.0; // 1.0 = Right, -1.0 = Left
  late AnimationController _sideSwapController;
  late Animation<double> _sideSwapAnim;
  
  // 3D Navigation State
  bool _isOverviewMode = false;
  late PageController _pageController;

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.settings_outlined,
    Icons.favorite_border,
    Icons.person_outline,
  ];

  @override
  void initState() {
    super.initState();
    // Start with sidebar open so user can see it
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 1.0,
    );
    // Side Swap Controller
    _sideSwapController = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 400),
    );
    _sideSwapController.addListener(() {
      setState(() {
        _sidebarAlign = _sideSwapAnim.value;
      });
    });
    
    // viewportFraction 1.0 for full screen
    _pageController = PageController(viewportFraction: 1.0, initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    // Horizontal (Sidebar)
    _controller.value -= details.delta.dx / _travelDistance;
    
    // Vertical (Handle Position)
    setState(() {
      final double screenHeight = MediaQuery.of(context).size.height;
      _handleYAlign += details.delta.dy / screenHeight;
      // Clamp to keep handle on screen (approx 10% from top/bottom margin)
      _handleYAlign = _handleYAlign.clamp(0.1, 0.9);
    });
  }

  void _onDragEnd(DragEndDetails details) {
     if (_controller.isDismissed || _controller.isCompleted) return;

     double velocityX = details.velocity.pixelsPerSecond.dx;

     // Velocity check for fling
     if (velocityX < -365.0) {
       _controller.forward(); // Fling open
     } else if (velocityX > 365.0) {
       _controller.reverse(); // Fling closed
     } else {
       // Snap to nearest
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
    return RepaintBoundary( // Optimize main content repaints
      key: const ValueKey('home_page'),
      child: Scaffold(
        backgroundColor: AppColors.midnightInk,
        body: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double animValue = _controller.value;
              
              // Dynamic Positioning based on _sidebarAlign (-1.0 Left to 1.0 Right)
              final double screenWidth = MediaQuery.of(context).size.width;
              
              // Normalize align (-1 to 1) to (0 to 1)
              final double t = (_sidebarAlign + 1) / 2; 
              
              // Define extremes
              final double leftOpen = 15.0;
              final double rightOpen = screenWidth - 15.0 - 60.0;
              final double leftClosed = -80.0;
              final double rightClosed = screenWidth + 20.0;
              
              // Interpolate States
              final double currentOpenPos = ui.lerpDouble(leftOpen, rightOpen, t)!;
              final double currentClosedPos = ui.lerpDouble(leftClosed, rightClosed, t)!;
              
              // Final Position based on Open/Close Animation
              final double sidebarLeft = ui.lerpDouble(currentClosedPos, currentOpenPos, animValue)!;
              
              // Content Margins
              // If align > 0 (Right), push content Left (Right Margin)
              // If align < 0 (Left), push content Right (Left Margin)
              final double marginVal = ui.lerpDouble(0, 70, animValue)!;
              final double contentRightMargin = _sidebarAlign > 0 ? marginVal : 0;
              final double contentLeftMargin = _sidebarAlign < 0 ? marginVal : 0;
              
              return Stack(
                children: [
                  /// SLIDER BAR (Appears from right)
                  /// SLIDER BAR
                  Positioned(
                    left: sidebarLeft,
                    // Sidebar Top moves with Handle Alignment
                    // Handle is at _handleYAlign * ScreenHeight
                    // We want Center of Sidebar to be at Handle Y
                    top: (MediaQuery.of(context).size.height * _handleYAlign) - (420.0 / 2),
                    child: RepaintBoundary( // Optimize sidebar repaints
                      key: const ValueKey('sidebar'),
                      child: _glassSideBar(),
                    ),
                  ),
        
                  /// MAIN CONTENT (Slides Away)
                  Container(
                    margin: EdgeInsets.only(
                      right: contentRightMargin,
                      left: contentLeftMargin,
                    ),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          // 3D Page View with Push-Back Effect
                          AnimatedScale(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            scale: _isOverviewMode ? 0.88 : 1.0,
                            child: RepaintBoundary( // Optimize PageView repaints
                              key: const ValueKey('page_view'),
                              child: PageView.builder(
                                controller: _pageController,
                                physics: _isOverviewMode
                                    ? const BouncingScrollPhysics() // Allow dragging in overview
                                    : const NeverScrollableScrollPhysics(), // Lock in normal mode
                                itemCount: icons.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return RepaintBoundary( // Optimize individual pages
                                    key: ValueKey('page_$index'),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        setState(() {
                                          _isOverviewMode = true;
                                        });
                                      },
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
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 350),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: _isOverviewMode ? 8 : 0,
                                          vertical: _isOverviewMode ? 50 : 0,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(_isOverviewMode ? 25 : 0),
                                          boxShadow: _isOverviewMode
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
                                          borderRadius: BorderRadius.circular(_isOverviewMode ? 25 : 0),
                                          child: _getPage(index),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Slider Handle (Draggable)
                  // Animate Handle across screen
                  Positioned(
                    left: ui.lerpDouble(0, screenWidth - 60.0, t),
                    top: MediaQuery.of(context).size.height * _handleYAlign,
                    child: RepaintBoundary( // Optimize handle repaints
                      key: const ValueKey('slider_handle'),
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent, // Ensure touches are caught even on transparent areas
                        onPanUpdate: _onDragUpdate,
                        onPanEnd: _onDragEnd,
                        onTap: _toggle,
                        child: Container(
                          color: Colors.transparent, // Invisible extend hit area
                          height: 120, // Taller hit area
                          width: 60,   // Wider hit area
                          padding: EdgeInsets.only(
                             left: _sidebarAlign > 0 ? 40 : 0, 
                             right: _sidebarAlign < 0 ? 40 : 0
                          ), 
                          child: Container(
                             height: 80,
                             width: 20,
                             decoration: BoxDecoration(
                               color: AppColors.graphiteSmoke.withOpacity(0.5),
                               borderRadius: BorderRadius.horizontal(
                                 left: _sidebarAlign > 0 ? const Radius.circular(20) : Radius.zero,
                                 right: _sidebarAlign < 0 ? const Radius.circular(20) : Radius.zero,
                               ),
                               boxShadow: [
                                 BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10)
                               ],
                               border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                             ),
                             child: Center(
                               child: Icon(
                                 // Dynamic icon based on state
                                 animValue > 0.5 
                                     ? (_sidebarAlign > 0 ? Icons.chevron_right : Icons.chevron_left)
                                     : (_sidebarAlign > 0 ? Icons.chevron_left : Icons.chevron_right), 
                                 color: Colors.white, size: 18
                               ),
                             ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ),
    );
  }

  Widget _glassSideBar() {
    // Reserve bottom space for the handle
    final double iconAreaHeight = 420.0 - 60.0;
    
    return GlassContainer(
      height: 420.0, // Explicit height to force update
      width: _sidebarWidth,
      borderRadius: 30,
      child: Listener(
        onPointerDown: (event) {
          // Check touch zone
          if (event.localPosition.dy > iconAreaHeight) {
             // Bottom Zone -> Move
             setState(() => _isMovingSidebar = true);
          } else {
             // Icon Zone -> Select
             setState(() => _isMovingSidebar = false);
          }
        },
        onPointerMove: (event) {
          final double screenWidth = MediaQuery.of(context).size.width;
          
          // Horizontal Drag (Move Sticky Side)
          if (event.delta.dx.abs() > 0.5) { 
             setState(() {
                _sidebarAlign += event.delta.dx / (screenWidth * 0.4); 
                _sidebarAlign = _sidebarAlign.clamp(-1.0, 1.0);
                _previewIndex = null; 
             });
          }

          if (_isMovingSidebar) {
             // Move Sidebar Vertically (Bottom Handle)
             setState(() {
                final double screenHeight = MediaQuery.of(context).size.height;
                _handleYAlign += event.delta.dy / screenHeight;
                _handleYAlign = _handleYAlign.clamp(0.1, 0.9);
             });
          } else {
             // Select Logic (Vertical Drag on Icons)
             final double itemHeight = iconAreaHeight / icons.length;
             final int index = (event.localPosition.dy / itemHeight).floor();
             if (index >= 0 && index < icons.length && index != _previewIndex) {
                 setState(() {
                   _previewIndex = index;
                 });
             }
          }
        },
        onPointerUp: (event) {
          // Horizontal Snap logic
          if ((_sidebarAlign.abs() - 1.0).abs() > 0.01) {
             double target = _sidebarAlign > 0 ? 1.0 : -1.0;
             if (!_sideSwapController.isAnimating) {
                 _sideSwapAnim = Tween<double>(begin: _sidebarAlign, end: target)
                     .animate(CurvedAnimation(parent: _sideSwapController, curve: Curves.elasticOut));
                 _sideSwapController.forward(from: 0);
             }
             setState(() {
               _isMovingSidebar = false;
               _previewIndex = null;
             });
             return;
          }

          if (_isMovingSidebar) {
             setState(() => _isMovingSidebar = false);
          } else {
             // Commit Selection
             final double itemHeight = iconAreaHeight / icons.length;
             // If preview exists use it, else calc from position
             int index = _previewIndex ?? (event.localPosition.dy / itemHeight).floor();
             
             if (index >= 0 && index < icons.length) {
                setState(() {
                  selectedIndex = index;
                  _previewIndex = null;
                  _controller.reverse(); // Close sidebar
                  if (_pageController.hasClients) {
                    _pageController.jumpToPage(selectedIndex);
                  }
                });
             } else {
                setState(() => _previewIndex = null);
             }
          }
        },
        child: Stack(
          children: [
             // Icons Area (Top)
             Positioned(
               top: 0,
               left: 0,
               right: 0,
               bottom: 60, // Leave space for handle
               child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(icons.length, (index) {
                    bool active = selectedIndex == index;
                    bool hovering = _previewIndex == index; // Highlight during drag
                    
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 40,
                      width: 40,
                      decoration: (active || hovering)
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withOpacity(hovering ? 0.4 : 0.2), // Brighter if hovering
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
             
             // Drag Handle Area (Bottom)
             Positioned(
               bottom: 0,
               left: 0,
               right: 0,
               height: 60,
               child: Center(
                 child: Container(
                   height: 6,
                   width: 30,
                   decoration: BoxDecoration(
                     color: Colors.transparent, // Invisible
                     borderRadius: BorderRadius.circular(3),
                   ),
                 ),
               ),
             )
          ],
        ),
      ),
    );
  }

  void _switchSide([bool? targetRight]) {
    if (_sideSwapController.isAnimating) return;
    final double target;
    if (targetRight != null) {
       target = targetRight ? 1.0 : -1.0;
    } else {
       target = _sidebarAlign > 0 ? -1.0 : 1.0;
    }
    if ((_sidebarAlign - target).abs() < 0.1) return;
    _sideSwapAnim = Tween<double>(begin: _sidebarAlign, end: target)
        .animate(CurvedAnimation(parent: _sideSwapController, curve: Curves.easeOutBack));
    _sideSwapController.forward(from: 0);
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const HomeFeed(key: ValueKey('Home'));
      case 1: return const ExplorePage(key: ValueKey('Explore'));
      case 2: return SettingsPage(
        key: const ValueKey('Settings'),
        isRightSide: _sidebarAlign > 0,
        onToggleSidebar: () => _switchSide(),
      );
      case 3: return const Center(child: Text("Notifications", style: TextStyle(color: Colors.white)));
      case 4: return const ProfilePage(key: ValueKey('Profile'));
      default: return const SizedBox.shrink();
    }
  }
}