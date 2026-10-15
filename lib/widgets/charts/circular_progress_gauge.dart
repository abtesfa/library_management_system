import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CircularProgressGauge extends StatelessWidget {
  final int current;
  final int target;
  final double size;

  const CircularProgressGauge({
    super.key,
    required this.current,
    required this.target,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (current / target).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage,
              strokeWidth: 7,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$current',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1,
                ),
              ),
              Text(
                '/$target',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}