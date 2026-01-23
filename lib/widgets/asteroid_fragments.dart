import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aura_app/theme/app_colors.dart';

class AsteroidFragments extends StatefulWidget {
  final Widget child;
  
  const AsteroidFragments({super.key, required this.child});

  @override
  State<AsteroidFragments> createState() => _AsteroidFragmentsState();
}

class _AsteroidFragmentsState extends State<AsteroidFragments>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<AsteroidFragment> _fragments = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Generate random asteroid fragments
    for (int i = 0; i < 15; i++) {
      _fragments.add(AsteroidFragment(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 40,
        rotation: _random.nextDouble() * 2 * pi,
        speed: 0.0001 + _random.nextDouble() * 0.0003,
        opacity: 0.05 + _random.nextDouble() * 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Asteroid fragments background
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: AsteroidPainter(_fragments, _controller.value),
              );
            },
          ),
        ),
        // Main content
        widget.child,
      ],
    );
  }
}

class AsteroidFragment {
  final double x;
  final double y;
  final double size;
  final double rotation;
  final double speed;
  final double opacity;

  AsteroidFragment({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.opacity,
  });
}

class AsteroidPainter extends CustomPainter {
  final List<AsteroidFragment> fragments;
  final double animationValue;

  AsteroidPainter(this.fragments, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var fragment in fragments) {
      final paint = Paint()
        ..color = AppColors.cosmicSilver.withOpacity(fragment.opacity)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = AppColors.nebulaGrey.withOpacity(fragment.opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Calculate position with slow drift
      final xPos = (fragment.x + animationValue * fragment.speed) % 1.0;
      final yPos = fragment.y;

      final center = Offset(xPos * size.width, yPos * size.height);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(fragment.rotation + animationValue * 0.5);

      // Draw irregular asteroid shape
      final path = Path();
      final points = 6;
      for (int i = 0; i < points; i++) {
        final angle = (i / points) * 2 * pi;
        final radius = fragment.size * (0.7 + Random(i).nextDouble() * 0.3);
        final x = cos(angle) * radius;
        final y = sin(angle) * radius;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(AsteroidPainter oldDelegate) => true;
}
