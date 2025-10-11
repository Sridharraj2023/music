import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  // Check individual password requirements
  bool get hasMinLength => password.length >= 8;
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar => password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  // Calculate password strength
  int get strengthScore {
    int score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasLowercase) score++;
    if (hasNumber) score++;
    if (hasSpecialChar) score++;
    return score;
  }

  String get strengthText {
    if (password.isEmpty) return '';
    if (strengthScore <= 2) return 'Weak';
    if (strengthScore <= 4) return 'Medium';
    return 'Strong';
  }

  Color get strengthColor {
    if (password.isEmpty) return Colors.grey;
    if (strengthScore <= 2) return Colors.red;
    if (strengthScore <= 4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (password.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password Strength Bar
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withOpacity(0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: strengthScore / 5,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: strengthColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              strengthText,
              style: TextStyle(
                color: strengthColor,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Password Requirements Checklist
        _buildRequirement('At least 8 characters', hasMinLength, screenWidth),
        _buildRequirement('One uppercase letter (A-Z)', hasUppercase, screenWidth),
        _buildRequirement('One lowercase letter (a-z)', hasLowercase, screenWidth),
        _buildRequirement('One number (0-9)', hasNumber, screenWidth),
        _buildRequirement('One special character (!@#\$%^&*)', hasSpecialChar, screenWidth),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: isMet ? Colors.green : Colors.red.withOpacity(0.7),
            size: screenWidth * 0.04,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: screenWidth * 0.032,
            ),
          ),
        ],
      ),
    );
  }
}

