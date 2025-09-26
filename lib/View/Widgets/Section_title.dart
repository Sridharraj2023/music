// widgets/section_title.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showIcon;

  const SectionTitle({super.key, required this.title, this.subtitle, this.showIcon = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
          ],
        ),
        if (showIcon)
          const Icon(LucideIcons.playCircle, size: 40, color: Colors.black),
      ],
    );
  }
}