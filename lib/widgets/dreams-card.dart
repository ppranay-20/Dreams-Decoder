import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DreamCard extends StatelessWidget {
  final dynamic chat;
  final navigateToChat;
  const DreamCard({super.key, required this.chat, required this.navigateToChat});

  @override
  Widget build(BuildContext context) {
    final String rawDate = chat['chat_open'];
    DateTime parsedDate = DateTime.parse(rawDate);
    final String day = DateFormat('EEE').format(parsedDate).toUpperCase(); 
    final String date = DateFormat('d').format(parsedDate);
    final String month = DateFormat('MMM').format(parsedDate).toUpperCase();
    final messages = chat['messages'] ?? [];
    final String firstMessage = messages.isNotEmpty ? messages[0]['content'] : "No messages";

    
    return GestureDetector(
      onTap: () => navigateToChat(chat),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.blue, // Background color for date box
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  firstMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}