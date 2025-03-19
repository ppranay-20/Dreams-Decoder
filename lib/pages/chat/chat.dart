import 'dart:convert';
import 'package:murkaverse/pages/questionaire/questionaire.dart';
import 'package:murkaverse/providers/chat-provider.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:murkaverse/widgets/end-chat.dart';
import 'package:murkaverse/widgets/main-screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> chat;
  final messageLimit;
  final charLimit;

  ChatPage({required this.chat, required this.charLimit, this.messageLimit});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool status = false;
  bool _isLoading = false;
  Map<String, dynamic>? chat;
  late int messageLimit;
  late int charaterLimit;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    messages = List<Map<String, dynamic>>.from(widget.chat['messages'] ?? []);
    status = widget.chat['status'] == "open" ? true : false;
    setState(() {
      messageLimit = widget.messageLimit;
      charaterLimit = widget.charLimit;
    });
  }

  Future<void> sendMessage() async {
    String userText = _messageController.text.trim();
    if (userText.isEmpty) return;
    var uuid = Uuid();

    if (messageLimit <= 0) {
      showErrorSnackBar(context, "You have reached the message limit");
      return;
    }

    Map<String, String> messagePayload = {
      "id": uuid.v4(),
      "chat_id": widget.chat['id'],
      "sent_by": "user",
      "sent": DateTime.now().toUtc().toIso8601String(),
      "content": userText
    };

    setState(() {
      messages.add(messagePayload);
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final url = getAPIUrl('message');

      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(messagePayload));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messageFromResonse = data['aiResponse'];
        setState(() {
          messages.add(messageFromResonse);
          messageLimit--;
        });

        if (context.mounted) {
          await Provider.of<UserProvider>(context, listen: false).getUserData();
          Provider.of<ChatProvider>(context, listen: false).refreshChats();
        }
      }
    } catch (e) {
      debugPrint("An error occured $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void endChat() {
    // showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text("End Chat",
    //             style: TextStyle(color: Colors.white, fontSize: 16)),
    //         backgroundColor: Color(0xFF180C12),
    //         content: Text("Do you really want to delete the chat?",
    //             style: TextStyle(color: Colors.white, fontSize: 13)),
    //         actions: [
    //           ElevatedButton(
    //             onPressed: () {
    //               Navigator.pop(context);
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.blue,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(25),
    //               ),
    //             ),
    //             child: Text("No", style: TextStyle(color: Colors.white)),
    //           ),
    //           ElevatedButton(
    //             onPressed: () async {
    //               try {
    //                 final chatProvider =
    //                     Provider.of<ChatProvider>(context, listen: false);
    //                 final updatedChat = await chatProvider.endCurrentChat();

    //                 if (updatedChat != null) {
    //                   setState(() {
    //                     chat = updatedChat;
    //                     status = updatedChat["status"] == "open" ? true : false;
    //                     showSuccessSnackbar(context, "Chat ended successfully");
    //                     Navigator.pop(context);
    //                     showEndChatQuestionnaire(context);
    //                   });
    //                 }
    //               } catch (e) {
    //                 debugPrint("An error occured $e");
    //               }
    //             },
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Color(0xFFDD4594),
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(25),
    //               ),
    //             ),
    //             child: Text("Yes", style: TextStyle(color: Colors.white)),
    //           ),
    //         ],
    //       );
    //     });

    showEndChatQuestionnaire(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color(0xFF180C12),
        leading: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFF330E22),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFDD4594),
              size: 20,
            ),
            onPressed: _isLoading
                ? null
                : () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MainScreen()));
                  },
          ),
        ),
        title: Text(
          "Dream Chat",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(left: 5, right: 5, top: 20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["sent_by"] == "user";
                bool isFirstMessage = index == 0 && !isUser;

                if (isFirstMessage) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            final catWidth = screenWidth * 0.3;
                            final catHeight = catWidth;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  top: -catHeight * 0.35,
                                  right: 0,
                                  child: Image.asset(
                                    "assets/cat3.png",
                                    width: catWidth,
                                    height: catHeight,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      top: catHeight * 0.4, bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(right: 8, top: 5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF301530),
                                          shape: BoxShape.circle,
                                        ),
                                        width: 30,
                                        height: 30,
                                        child: Image.asset(
                                          "assets/chat_cat.png",
                                          width: 30,
                                          height: 30,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF330E22),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            messages[index]["content"]!,
                                            style: TextStyle(
                                                color: Color(0xFFDFBAEF)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Container(
                            margin: EdgeInsets.only(right: 8, top: 5),
                            decoration: BoxDecoration(
                              color: Color(0xFF330E22),
                              shape: BoxShape.circle,
                            ),
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              "assets/chat_cat.png",
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                            ),
                          ),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width *
                                    0.8, // Limit bubble width
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Color(0xFF051D2D)
                                    : Color(0xFF330E22),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                messages[index]["content"]!,
                                style: TextStyle(
                                    color: isUser
                                        ? Color(0xFFA0DBFF)
                                        : Color(0xFFDFBAEF)),
                              ),
                            ),
                            if (index == messages.length - 1 &&
                                status &&
                                !isUser)
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child:
                                    buildChatCreditsBar(messageLimit, endChat),
                              ),
                          ],
                        ),
                      ]),
                );
              },
            ),
          ),
          Padding(
              padding: EdgeInsets.all(8),
              child: !status
                  ? Center(
                      child: Text(
                        "Your chat is closed",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _messageController,
                                onChanged: (value) {
                                  setState(() {
                                    setState(() {});
                                  });
                                },
                                style: TextStyle(color: Colors.white),
                                maxLength:
                                    charaterLimit, // Add this to limit text input
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF051D2D),
                                  hintText: "Message",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide:
                                        BorderSide(color: Color(0xFF1972A9)),
                                  ),
                                  counterText: _messageController.text.length >=
                                          charaterLimit
                                      ? "You have reached the charater limit of $charaterLimit"
                                      : "",
                                  counterStyle: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: _isLoading ? null : sendMessage,
                          backgroundColor: Color(0xFF1972A9),
                          shape: CircleBorder(),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    )),
        ],
      ),
    );
  }
}
