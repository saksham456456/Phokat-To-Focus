import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring representing focus circle
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: size * 0.1,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.4),
                  width: size * 0.08,
                ),
              ),
            ),
            // Inner circle / Target
            Container(
              width: size * 0.35,
              height: size * 0.35,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // The "Target" icon
            Icon(
              Icons.center_focus_strong_rounded,
              size: size * 0.5,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ],
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: -0.5,
              ),
              children: [
                const TextSpan(text: 'Phokat'),
                TextSpan(
                  text: 'To',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const TextSpan(text: 'Focus'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
