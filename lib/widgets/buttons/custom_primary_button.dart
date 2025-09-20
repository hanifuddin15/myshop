import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? height;
  final double? fontSize;

  const CustomPrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height = 48,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        padding: EdgeInsets.symmetric(vertical: height! * 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: Size.fromHeight(height!),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
