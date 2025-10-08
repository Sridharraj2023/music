// views/widgets/feature_row.dart
import 'package:flutter/material.dart';

class FeatureRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmphasized;

  const FeatureRow({
    required this.label, 
    required this.value,
    this.isEmphasized = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: isEmphasized ? Colors.white : Colors.white.withOpacity(0.5),
                ),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontWeight: isEmphasized ? FontWeight.bold : FontWeight.normal,
                      color: isEmphasized ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}