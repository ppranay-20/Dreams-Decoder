import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> chat;

  ChatPage({required this.chat});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool status = false;
  bool _isLoading = false;
  Map<String, dynamic>? chat;
  late int messageLimit = 0;
  late int charaterLimit = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    messages = List<Map<String, dynamic>>.from(widget.chat['messages'] ?? []);
    status = widget.chat['status'] == "open" ? true : false;
    getMessageLimit();
  }

  void getMessageLimit() async {
    final userId = await getIdFromJWT();
    final url = getAPIUrl('users/$userId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          messageLimit = data['data']['message_limit'] ?? 0;
          charaterLimit = data['data']['charater_limit'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("An error occured $e");
    }
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
                        Navigator.pop(context);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Murka Chat", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          status
              ? TextButton(
                  onPressed: () {
                    endChat();
                  },
                  child: Text(
                    "End Chat",
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.normal),
                  ))
              : SizedBox()
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Column(
              children: [
                Text(
                  "Welcome to Murkaverse, let's get to decoding your dreams!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.message, color: Colors.white70, size: 16),
                      SizedBox(width: 5),
                      Text(
                        "Messages: $messageLimit",
                        style: TextStyle(color: Colors.white70),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple.shade700,
                              image: DecorationImage(
                                image: AssetImage('assets/murka.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width *
                                0.7, // Limit bubble width
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blueAccent
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            messages[index]["content"]!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ]),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.blueAccent),
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
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade900,
                              hintText: "Type a message...",
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        FloatingActionButton(
                          onPressed: sendMessage,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    )),
        ],
      ),
    );
  }
}
