import 'package:flutter/material.dart';

class MojiStatBar extends StatelessWidget {
  const MojiStatBar({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF22D3EE)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}
