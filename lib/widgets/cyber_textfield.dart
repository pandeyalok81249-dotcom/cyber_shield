import 'package:flutter/material.dart';

class CyberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const CyberTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFF0B111A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}