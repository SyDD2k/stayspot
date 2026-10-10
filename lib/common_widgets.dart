import 'package:flutter/material.dart';

/// A reusable widget for displaying the app title with an animated scale.
class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 60,
            height: 60,
          ),
          const SizedBox(width: 10),
          const Text(
            'StaySpot',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Color(0xff007BFF),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show a dialog.
void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  VoidCallback? onOkPressed,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onOkPressed ?? () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
