import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({
    super.key,
    required this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller with total duration of 5 seconds (1s fade in + 3s visible + 1s fade out)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    // Create fade in animation for first second (0-0.2 of total time)
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );
    
    // Create fade out animation for last second (0.8-1.0 of total time)
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Start the animation
    _animationController.forward();
    
    // Navigate to the next screen after animation completes
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => widget.nextScreen),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Calculate opacity based on animation progress
            double opacity = 0.0;
            
            if (_animationController.value <= 0.2) {
              // First 20% of time (1s) - fade in
              opacity = _fadeInAnimation.value;
            } else if (_animationController.value >= 0.8) {
              // Last 20% of time (1s) - fade out
              opacity = _fadeOutAnimation.value;
            } else {
              // Middle 60% of time (3s) - fully visible
              opacity = 1.0;
            }
            
            return Opacity(
              opacity: opacity,
              child: Image.asset(
                'assets/images/logo.png',
                width: 200,
                height: 200,
              ),
            );
          },
        ),
      ),
    );
  }
} 