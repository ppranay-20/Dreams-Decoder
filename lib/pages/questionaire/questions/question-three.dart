import 'package:flutter/material.dart';

class QuestionThree extends StatelessWidget {
  final Function(bool) onChanged;
  final bool nightmare;
  const QuestionThree(
      {super.key, required this.onChanged, required this.nightmare});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "3. Was this dream a nightmare?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        _radioButton("Yes", true, context, nightmare, onChanged),
        SizedBox(height: 10),
        _radioButton("No", false, context, nightmare, onChanged),
      ],
    );
  }

  Widget _radioButton(String text, bool value, BuildContext context,
      bool nightmare, Function(bool) onChanged) {
    bool isSelected = nightmare == value;
    return GestureDetector(
      onTap: () {
        onChanged(value);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF231427),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Color(0xFFE361CF), size: 16)
                  : Icon(Icons.check, color: Colors.grey, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
