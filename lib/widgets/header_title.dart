import 'package:flutter/material.dart';

class HeaderTitle extends StatelessWidget {
  const HeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.shield, size: 34, color: Colors.cyanAccent),
        SizedBox(width: 10),
        Text(
          "Cyber Shield",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
