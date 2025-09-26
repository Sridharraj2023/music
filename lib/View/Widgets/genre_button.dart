// widgets/genre_button.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GenreButton extends StatelessWidget {
  final String label;

  const GenreButton({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE6FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(LucideIcons.playCircle, color: Colors.black, size: 30),
SizedBox(width: 20,),
          Text(
            label,
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}