import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:project/Widgets/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _lineWidth;
  late Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    // Text animations
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Horizontal line animation
    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeInOut),
      ),
    );

    // Progress animation
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _controller.forward();

    // Navigate to sign-in screen after delay
    Timer(const Duration(milliseconds: 3000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) => const SignInScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // Purple-tinted dark background
      backgroundColor: const Color(0xFF120E24),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              // Purple gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.3),
                    radius: 1.0,
                    colors: [
                      Color(0xFF2A1B54),
                      Color(0xFF120E24),
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),

              // Subtle purple particles
              Positioned.fill(
                child: CustomPaint(
                  painter: PurpleParticlesPainter(
                    progress: _controller.value,
                  ),
                ),
              ),

              // Center logo and text
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with fade and scale animation
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          height: 160,
                          width: 160,
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x339D78FF), // Purple glow
                                blurRadius: 25,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset("assets/icons/logo.png"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Text with fade animation
                    Opacity(
                      opacity: _textOpacity.value,
                      child: Column(
                        children: [
                          const Text(
                            "IIT Hub.AI",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Empowering Students with AI",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD9C5FF), // Light purple text
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Animated horizontal line with purple gradient
                          Container(
                            width: 100 * _lineWidth.value,
                            height: 2,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF9D78FF), // Bright purple
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom progress indicator
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: _progressValue.value,
                              backgroundColor: const Color(0xFF261A40), // Dark purple
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9D78FF)), // Bright purple
                              minHeight: 3,
                            ),
                          ),
                        ),

                        if (_progressValue.value > 0.5)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Text(
                              "LOADING",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFB5A1E0), // Light purple
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Purple circular focus element
              Positioned.fill(
                child: CustomPaint(
                  painter: PurpleFocusRingPainter(
                    progress: _controller.value,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Enhanced circular focus ring with purple theme
class PurpleFocusRingPainter extends CustomPainter {
  final double progress;

  PurpleFocusRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.32;

    // Only draw when animation has started
    if (progress < 0.05) return;

    // Draw a subtle purple circular ring
    final ringPaint = Paint()
      ..color = const Color(0x26A355FF) // Transparent purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw outer glow
    final outerRingPaint = Paint()
      ..color = const Color(0x128652FF) // Very transparent purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius + 5, outerRingPaint);

    // Draw a few subtle purple dot markers on the ring
    const markerCount = 4;
    final markerPaint = Paint()
      ..color = const Color(0x40A355FF) // Semi-transparent purple
      ..style = PaintingStyle.fill;

    for (int i = 0; i < markerCount; i++) {
      // Calculate position on the circle
      final angle = (i / markerCount) * 2 * math.pi;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      // Draw small circle
      canvas.drawCircle(Offset(x, y), 2.5, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PurpleFocusRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Purple particles background effect
class PurpleParticlesPainter extends CustomPainter {
  final double progress;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  PurpleParticlesPainter({required this.progress}) {
    // Initialize particles on first paint
    if (_particles.isEmpty) {
      for (int i = 0; i < 25; i++) {
        _particles.add(Particle(_random));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;

    for (final particle in _particles) {
      // Update particle position based on progress
      final x = size.width * particle.x;
      final y = size.height * particle.y;

      // Calculate opacity based on progress and particle's own opacity
      final opacity = progress * particle.opacity;

      // Draw the particle
      final paint = Paint()
        ..color = Color.fromRGBO(
            particle.color.red,
            particle.color.green,
            particle.color.blue,
            opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PurpleParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Helper class for particle effect
class Particle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double opacity;

  Particle(math.Random random) :
        x = random.nextDouble(),
        y = random.nextDouble(),
        size = random.nextDouble() * 2.5 + 0.5,
        color = Color.fromRGBO(
            157 + random.nextInt(40), // Red
            120 + random.nextInt(50), // Green
            255,                      // Blue
            1.0),
        opacity = random.nextDouble() * 0.2 + 0.05;
}