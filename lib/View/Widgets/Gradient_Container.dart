// views/widgets/gradient_container.dart
import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;

  const GradientContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3A55F8), // Top blue
            Color(0xFF6F41F3), // Middle purple
            Color(0xFF8A2BE2), // Bottom violet
          ],
        ),
      ),
      child: child,
    );
  }
}