import 'package:flutter/material.dart';

class QuestionFour extends StatefulWidget {
  final String dreamDescription;
  final Function(String) onChanged;

  const QuestionFour({
    super.key,
    required this.dreamDescription,
    required this.onChanged,
  });

  @override
  State<QuestionFour> createState() => _QuestionFourState();
}

class _QuestionFourState extends State<QuestionFour> {
  @override
  void dispose() {
    // Clean up controller when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "4. Describe your dream",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 16),
        TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Type your dream description here...",
            hintStyle: TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Color(0xFF231427),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white54),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE361CF)),
            ),
            contentPadding: EdgeInsets.all(16),
          ),
          maxLines: 5,
          onChanged: (value) {
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}
