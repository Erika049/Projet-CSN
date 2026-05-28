import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final Color? activeColor;
  final bool showLabels;

  const AppStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final double circleSize = _computeCircleSize(screenWidth, steps.length);
    final double fontSize = _computeFontSize(screenWidth, steps.length);
    final bool canShowLabels =
        showLabels && _canShowLabels(screenWidth, steps.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // ===== Rangée 1 : cercles + lignes =====
          Row(
            children: List.generate(steps.length * 2 - 1, (slot) {
              // Slots pairs = cercles, slots impairs = lignes
              if (slot.isEven) {
                final i = slot ~/ 2;
                final isActive = i == currentStep;
                final isDone = i < currentStep;
                return _StepCircle(
                  index: i,
                  isActive: isActive,
                  isDone: isDone,
                  color: color,
                  size: circleSize,
                  fontSize: fontSize,
                );
              } else {
                // Ligne entre deux cercles : occupe tout l'espace dispo
                final leftIndex = slot ~/ 2;
                final isDone = leftIndex < currentStep;
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDone ? color : AppColors.border,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }
            }),
          ),

          // ===== Rangée 2 : labels centrés sous chaque cercle =====
          if (canShowLabels) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(steps.length, (i) {
                final isActive = i == currentStep;
                final isDone = i < currentStep;
                return Expanded(
                  child: Text(
                    steps[i],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? color
                          : isDone
                          ? AppColors.textMedium
                          : AppColors.textLight,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  double _computeCircleSize(double screenWidth, int stepCount) {
    if (stepCount <= 3) { return 28; }
    if (stepCount <= 5) { return screenWidth < 360 ? 24 : 26; }
    return screenWidth < 360 ? 20 : 22;
  }

  double _computeFontSize(double screenWidth, int stepCount) {
    if (stepCount <= 3) { return 12; }
    if (stepCount <= 5) { return 11; }
    return 10;
  }

  bool _canShowLabels(double screenWidth, int stepCount) {
    final needed = stepCount * 60.0;
    return screenWidth >= needed;
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isDone;
  final Color color;
  final double size;
  final double fontSize;

  const _StepCircle({
    required this.index,
    required this.isActive,
    required this.isDone,
    required this.color,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone || isActive ? color : AppColors.surfaceLight,
        border: Border.all(
          color: isActive || isDone ? color : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check, color: Colors.white, size: size * 0.5)
            : Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}