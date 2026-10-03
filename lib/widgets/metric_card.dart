import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 166,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(.12),
            const Color(0xFF0C1A29),
          ],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: color.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Icon(Icons.arrow_outward_rounded, size: 15, color: color.withOpacity(.65)),
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}
