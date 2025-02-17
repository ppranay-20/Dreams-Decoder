import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dreams_decoder/pages/chat/chat.dart';
import 'package:dreams_decoder/pages/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class DreamHistory extends StatefulWidget {
  const DreamHistory({super.key});

  @override
  State<DreamHistory> createState() => _DreamHistoryState();
}

class _DreamHistoryState extends State<DreamHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser?.uid ?? "";

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                /// Header Row (Title + Profile Icon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dream History",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Profile()),
                        );
                      },
                      child: Icon(Icons.account_circle, color: Colors.white, size: 30),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                /// Fetch and Display Dream List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("Dreams")
                        .where("userId", isEqualTo: currentUserId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text("No dreams found", style: TextStyle(color: Colors.white70)),
                        );
                      }

                      final dreams = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: dreams.length,
                        itemBuilder: (context, index) {
                          var dream = dreams[index];
                          var dreamId = dream.id;
                          var timestamp = dream["createdAt"] as Timestamp?;
                          var date = timestamp != null
                              ? DateFormat("dd MMM yyyy, hh:mm a").format(timestamp.toDate())
                              : "Unknown Date";

                          // Extract first chat message
                          List<dynamic> chats = dream["chats"] ?? [];
                          String firstMessage = chats.isNotEmpty
                              ? chats[0]["text"] ?? "No message available"
                              : "No message available";

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ChatPage(dreamId: dreamId)),
                              );
                            },
                            child: _buildDreamCard(date, firstMessage),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// Floating Button (+) to Add a New Dream
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(dreamId: null)));
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  /// Dream History Card UI
  Widget _buildDreamCard(String date, String firstMessage) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 5),
          Text(
            firstMessage,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
