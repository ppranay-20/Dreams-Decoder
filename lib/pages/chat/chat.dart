import 'dart:convert';
import 'package:dreams_decoder/pages/questionaire/questionaire.dart';
import 'package:dreams_decoder/providers/user-provider.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("End Chat"),
            content: Text("Do you really want to delete the chat?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No", style: TextStyle(color: Colors.blueAccent)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final chatId = widget.chat['id'];
                    final url = getAPIUrl('chat/end-chat/$chatId');

                    final response = await http.put(url,
                        body: jsonEncode({"status": "closed"}));

                    if (response.statusCode == 200) {
                      final data = jsonDecode(response.body);
                      final updatedChat = data['data'];

                      setState(() {
                        chat = updatedChat;
                        status = updatedChat["status"] == "open" ? true : false;
                        showSuccessSnackbar(context, "Chat ended successfully");
                        showEndChatQuestionnaire(context);
                      });
                    }
                  } catch (e) {
                    debugPrint("An error occured $e");
                  }
                },
                child: Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFF180E18),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 10, top: 10, bottom: 10),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFFE152C2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          "Dream Chat",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              endChat();
            },
            child: Text("End Chat", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUser = messages[index]["sent_by"] == "user";
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
                              color: Color(0xFF301530),
                              shape: BoxShape.circle,
                            ),
                            width: 30,
                            height: 30,
                            child: Icon(Icons.star, color: Color(0xFFE152C2)),
                          ),
                        if (index == 0 && messages.isNotEmpty)
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset("cat3.png"),
                          ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.7, // Limit bubble width
                          ),
                          decoration: BoxDecoration(
                            color:
                                isUser ? Color(0xFF101D3C) : Color(0xFF301530),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            messages[index]["content"]!,
                            style: TextStyle(
                                color: isUser
                                    ? Color(0xFF8EABED)
                                    : Color(0xFFDFBAEF)),
                          ),
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
                                style: TextStyle(color: Colors.white),
                                maxLength:
                                    charaterLimit, // Add this to limit text input
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF101D3C),
                                  hintText: "Type a message...",
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  counterText: "", // Hide the default counter
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: _isLoading ? null : sendMessage,
                          backgroundColor: Colors.blueAccent,
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
