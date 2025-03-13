import 'package:flutter/material.dart';

Widget buildChatCreditsBar(int messageLimit, VoidCallback endChat) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 30,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF4A1D4A),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFE361CF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                messageLimit.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  "FILL UP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
      Text(
        "$messageLimit messages are left",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          endChat();
        },
        child: Text(
          "End Chat",
          style: TextStyle(
            color: Color(0xFF699DFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}
