import 'package:flutter/material.dart';
import 'package:ventables/config/theme.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final double borderRadius;

  const GradientContainer({
    Key? key,
    required this.child,
    this.gradient = AppTheme.primaryGradient,
    this.borderRadius = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
