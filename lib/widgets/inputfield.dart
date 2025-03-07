import 'package:flutter/material.dart';

class Inputfield extends StatelessWidget {
  const Inputfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: false,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Name",
        hintText: "Enter Email",
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}