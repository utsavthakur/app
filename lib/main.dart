// ignore_for_file: deprecated_member_use
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:aura_app/home_feed.dart';
import 'package:aura_app/explore_page.dart';
import 'package:aura_app/profile_page.dart';
import 'package:aura_app/settings_page.dart';
import 'package:aura_app/widgets/glass_container.dart';
import 'package:aura_app/theme/app_colors.dart';

import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const AuraApp(),
    ),
  );
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int selectedIndex = 0;

  // Sidebar parameters
  static const double _sidebarWidth = 60.0;
  static const double _closedRight = -80.0;
  static const double _openRight = 15.0;
  static const double _travelDistance = _openRight - _closedRight; // 95.0
  
  double _handleYAlign = 0.45;
  int? _previewIndex; // For slide-to-select feedback
  
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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 1.0,
    );
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
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double animValue = _controller.value;
            // Calculations
            final double sidebarRight = ui.lerpDouble(_closedRight, _openRight, animValue)!;
            final double contentRightMargin = ui.lerpDouble(0, 70, animValue)!;
            final double handleRight = ui.lerpDouble(0, 75, animValue)!;
            
            // Content Scale/Fade is coupled to the sidebar opening? 
            // Original code didn't scale content based on sidebar, it just shifted margin.
            // But let's add a subtle scale for "3D" feel if desired, or stick to margin shift.
            // Original: margin: EdgeInsets.only(right: isOpen ? 70 : 0)
            
            return Stack(
              children: [
                /// SLIDER BAR (Appears from right)
                Positioned(
                  right: sidebarRight,
                  top: MediaQuery.of(context).size.height * 0.2, 
                  child: _glassSideBar(),
                ),
      
                /// MAIN CONTENT (Slides Left)
                Container(
                  margin: EdgeInsets.only(right: contentRightMargin),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        // 3D Page View with Push-Back Effect
                        AnimatedScale(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          scale: _isOverviewMode ? 0.88 : 1.0,
                          child: PageView.builder(
                            key: const ValueKey('main_page_view'),
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
                              return GestureDetector(
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
                              );
                            },
                          ),
                        ),
                        
                        // Slider Handle (Draggable)
                        Positioned(
                          right: handleRight, 
                          top: MediaQuery.of(context).size.height * _handleYAlign,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent, // Ensure touches are caught even on transparent areas
                            onPanUpdate: _onDragUpdate,
                            onPanEnd: _onDragEnd,
                            onTap: _toggle,
                            child: Container(
                              color: Colors.transparent, // Invisible extend hit area
                              height: 120, // Taller hit area
                              width: 60,   // Wider hit area (20 visual + 40 invisible)
                              padding: const EdgeInsets.only(left: 40), // Push visual to the right side of hit area
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
                                     // Dynamic icon based on state
                                     animValue > 0.5 ? Icons.chevron_right : Icons.chevron_left, 
                                     color: Colors.white, size: 18
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
    );
  }

  Widget _glassSideBar() {
    return GlassContainer(
      height: 360,
      width: _sidebarWidth,
      borderRadius: 30,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (details) {
          // Click to navigate
          final double itemHeight = 360.0 / icons.length;
          final int index = (details.localPosition.dy / itemHeight).floor();
          
          if (index >= 0 && index < icons.length) {
            setState(() {
              selectedIndex = index;
              _controller.reverse(); // Close sidebar
              
              // Sync PageView
              if (_pageController.hasClients) {
                _pageController.jumpToPage(selectedIndex);
              }
            });
          }
        },
        onVerticalDragUpdate: (details) {
          // Drag to preview
          final double itemHeight = 360.0 / icons.length;
          final int index = (details.localPosition.dy / itemHeight).floor();
          
          if (index >= 0 && index < icons.length && index != _previewIndex) {
            setState(() {
              _previewIndex = index;
            });
          }
        },
        onVerticalDragEnd: (details) {
          if (_previewIndex != null) {
            setState(() {
              selectedIndex = _previewIndex!;
              _previewIndex = null;
              _controller.reverse(); // Close after selection
              
              // Sync PageView
              if (_pageController.hasClients) {
                _pageController.jumpToPage(selectedIndex);
              }
            });
          }
        },
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
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0: return const HomeFeed(key: ValueKey('Home'));
      case 1: return const ExplorePage(key: ValueKey('Explore'));
      case 2: return const SettingsPage(key: ValueKey('Settings'));
      case 3: return const Center(child: Text("Notifications", style: TextStyle(color: Colors.white)));
      case 4: return const ProfilePage(key: ValueKey('Profile'));
      default: return const SizedBox.shrink();
    }
  }
}
