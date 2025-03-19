import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:murkaverse/pages/chat/chat.dart';
import 'package:murkaverse/pages/questionaire/questionaire.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:murkaverse/providers/chat-provider.dart';

void showCustomDialog(BuildContext context, Map<String, dynamic> chat) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Color(0xFF180C12), // Dark background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF8B2359),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFFDD4594),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "Your previous chat is still open",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          // Description
                          Text(
                            "Would you like to end the previous chat to start a new one?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                // End Previous Chat Button
                Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ElevatedButton(
                      onPressed: () {
                        if (chatProvider.endChatLoading) {
                          showErrorSnackBar(
                              context, "Please wait for the chat to end");
                          return;
                        }
                        chatProvider.endCurrentChat();
                        Navigator.pop(context);
                        showEndChatQuestionnaire(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDD4594),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: chatProvider.endChatLoading
                          ? Text(
                              "Ending chat...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Text(
                              "End Previous Chat",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                    );
                  },
                ),
                SizedBox(height: 8),

                Text(
                  "Go and continue your previous chat",
                  style: TextStyle(
                      color: Colors.white60, fontSize: 13, letterSpacing: 0.4),
                ),

                SizedBox(height: 4),
                // Previous Chat Link
                GestureDetector(
                  onTap: () {
                    Provider.of<ChatProvider>(context, listen: false);
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    final charLimit =
                        userProvider.userData?['character_limit'] as int;
                    final messageLimit =
                        userProvider.userData?['message_limit'] as int;

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                chat: chat,
                                charLimit: charLimit,
                                messageLimit: messageLimit)));
                  },
                  child: Text(
                    "Previous Chat",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
