import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DreamCard extends StatelessWidget {
  final dynamic chat;
  final Function navigateToChat;

  const DreamCard(
      {super.key, required this.chat, required this.navigateToChat});

  @override
  Widget build(BuildContext context) {
    final String rawDate = chat['chat_open'];
    DateTime parsedDate = DateTime.parse(rawDate);
    final String date = DateFormat('MMM d').format(parsedDate);
    final messages = chat['messages'] ?? [];
    final String firstMessage =
        messages.isNotEmpty ? messages[0]['content'] : "No messages";

    return GestureDetector(
      onTap: () => navigateToChat(chat),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFF733683), width: 1),
          color: Color(0xFF160816),
          borderRadius: BorderRadius.circular(12),
        ),
        // Use IntrinsicHeight to ensure both sides have the same height
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Message content - takes available space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    firstMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ),
              ),

              // Right side panel with two different colored sections
              SizedBox(
                width: 70, // Fixed width for the right panel
                child: Column(
                  children: [
                    // Top section with darker purple and date
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            Color(0xFF733683), // Darker purple for top section
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(11),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          date,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Bottom section with lighter purple and "Full chat"
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(
                              0xFF3D1F3D), // Lighter purple for bottom section
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 3, top: 20, right: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Full chat >",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
