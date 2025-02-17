import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String? dreamId;

  ChatPage({this.dreamId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? dreamId;

  late GenerativeModel model;

  @override
  void initState() {
    String apikey = dotenv.env['API_KEY'] as String;

    if(apikey.isEmpty) {
      throw Exception("API Key is missing");
    }

    super.initState();
    model = GenerativeModel(model: 'gemini-pro', apiKey: apikey);
    _setupChat();
  }

  Future<void> _setupChat() async {
    dreamId = widget.dreamId ?? await _createNewDream();
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (dreamId == null) return;
    var dreamDoc = await FirebaseFirestore.instance
        .collection("Dreams")
        .doc(dreamId)
        .get();

    if (dreamDoc.exists) {
      List<dynamic> fetchedMessages = dreamDoc["chats"] ?? [];
      setState(() {
        _messages.clear();
        _messages.addAll(fetchedMessages
            .map((msg) => {"sender": msg["sender"], "text": msg["text"]}));
      });

      if(fetchedMessages.isNotEmpty && fetchedMessages.last["sender"] == "ai") {
        var lastMessage = fetchedMessages.last;
        Timestamp lastTimestamp = lastMessage["created_at"]; // Firestore timestamp
        DateTime lastMessageTime = lastTimestamp.toDate();
        DateTime currentTime = DateTime.now();

        if(currentTime.difference(lastMessageTime).inMinutes > 10) {
          await FirebaseFirestore.instance
            .collection("Dreams")
            .doc(dreamId)
            .update({"status": "end"});
        }
      }

    }
  }

  Future<String> _createNewDream() async {
    var user = FirebaseAuth.instance.currentUser;
    var doc = await FirebaseFirestore.instance.collection("Dreams").add({
      "userId": user?.uid,
      "chats": [],
      "status": "new",
      "createdAt": FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> sendMessage() async {
    String userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": userText});
      _messageController.clear();
      _isLoading = true;
    });

    try {
      final content = Content.text("Answer concisely in **under 100 characters**. Be brief and to the point: $userText");
      final response = await model.generateContent([content]);
      String botResponse =
          response.text ?? "Sorry, I couldn't understand that.";

      setState(() {
        _messages.add({"sender": "ai", "text": botResponse});
      });

      await _updateFirestoreMessages(userText, botResponse);
    } catch (e) {
      setState(() {
        _messages
            .add({"sender": "ai", "text": "Error: Failed to get a response."});
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateFirestoreMessages(
      String userText, String botResponse) async {
    if (dreamId == null) return;
    await FirebaseFirestore.instance.collection("Dreams").doc(dreamId).update({
      "chats": FieldValue.arrayUnion([
        {"sender": "user", "text": userText, "created_at": DateTime.now()},
        {"sender": "ai", "text": botResponse, "created_at": DateTime.now()},
      ])
    });
  }

  Future<int> findMessageLimit() async {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == "") {
      throw Exception("User ID is null or empty");
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("User")
          .where("user_id", isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        if (data.containsKey("message_limit")) {
          return data["message_limit"] as int;
        } else {
          throw Exception("No message limit found in Firestore.");
        }
      } else {
        throw Exception("No user data found in Firestore.");
      }
    } catch (e) {
      debugPrint("Error fetching message limit: $e");
      rethrow;
    }
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
                    await FirebaseFirestore.instance
                        .collection("Dreams")
                        .doc(dreamId)
                        .update({"status": "end"});
                        setState(() {});
                  } catch (e) {
                    debugPrint("Error in deleteing the message $e");
                  } // End the chat
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
  }

  Future<bool> isChatOpen() async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("Dreams")
          .doc(dreamId)
          .get();

      if (doc.exists) {
        var data = doc.data();
        return data?["status"] == "new";
      }
    } catch (e) {
      debugPrint("Error fetching chat status: $e");
    }
    return false;
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
        title: Text("Dream Decoder", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          FutureBuilder(
              future: isChatOpen(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return TextButton(
                      onPressed: () {
                        endChat();
                      },
                      child: Text(
                        "End Chat",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.normal),
                      ));
                }

                return SizedBox();
              })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "Welcome to Dream Decoder, let's get to decoding your dreams!",
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
                      FutureBuilder(
                          future: findMessageLimit(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text("Loading...",
                                  style: TextStyle(color: Colors.white70));
                            } else if (snapshot.hasError) {
                              return Text(snapshot.error.toString(),
                                  style: TextStyle(color: Colors.red));
                            } else {
                              int messageLimit = snapshot.data!;
                              return Text(
                                "Messages: ${(_messages.length).toInt()}/$messageLimit",
                                style: TextStyle(color: Colors.white70),
                              );
                            }
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]["sender"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _messages[index]["text"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
            padding: EdgeInsets.all(10),
            child: FutureBuilder<bool>(
              future: isChatOpen(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    "Checking chat status",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  );
                }

                if (snapshot.hasError || snapshot.data == false) {
                  return Center(
                    child: Text(
                      "Your chat is closed",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }

                return Row(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
