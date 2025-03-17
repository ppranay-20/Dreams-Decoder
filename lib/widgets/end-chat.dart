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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A1D4A), // Dark purple-pink at top
              Color(0xFF2D0B2D), // Mid purple
              Color(0xFF1A061A), // Darker purple
              Color(0xFF2D0B2D), // Returns to mid purple
              Color(0xFF380D38), // Slightly lighter purple at bottom
            ],
            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE361CF),
              blurRadius: 6,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Color(0xFFDD4594),
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
                  textAlign: TextAlign.center,
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
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4),
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4),
        ),
      ),
    ],
  );
}
