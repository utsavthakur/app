import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ShaderBackground extends StatefulWidget {
  final Widget child;
  const ShaderBackground({super.key, required this.child});

  @override
  State<ShaderBackground> createState() => _ShaderBackgroundState();
}

class _ShaderBackgroundState extends State<ShaderBackground> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _initShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  Future<void> _initShader() async {
    try {
      final program = await FragmentProgram.fromAsset('shaders/aurora.frag');
      setState(() {
        _program = program;
      });
    } catch (e) {
      debugPrint("Shader loading failed: $e");
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return Container(
        color: Colors.black,
        child: widget.child,
      );
    }

    return CustomPaint(
      painter: _ShaderPainter(_program!, _time),
      child: widget.child,
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final FragmentProgram program;
  final double time;

  _ShaderPainter(this.program, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // Uniforms:
    // float iTime (index 0)
    // vec2 iResolution (index 1, 2)
    
    final shader = program.fragmentShader();
    shader.setFloat(0, time);
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.program != program;
  }
}
