import 'dart:convert';

import 'package:dreams_decoder/pages/home/dream-table.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:dreams_decoder/pages/chat/chat.dart';
import 'package:dreams_decoder/pages/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DreamHistory extends StatefulWidget {
  const DreamHistory({super.key});

  @override
  State<DreamHistory> createState() => _DreamHistoryState();
}

class _DreamHistoryState extends State<DreamHistory> {
  bool isLoading = true;
  List<dynamic> chats = [];
  DateTime? selectedDate;
  Map<DateTime, List<dynamic>> events = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllChats();
  }


  void getAllChats() async {
    final customerId = await getIdFromJWT();
    try {
      final url = getAPIUrl('chat/user/$customerId');
      
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json'
      });

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
      
        setState(() {
          isLoading = false;
          chats = data['data'];
          events = _groupChatsByDate(chats);
          DateTime now = DateTime.now();
          DateTime normalizedDate = DateTime(now.year, now.month, now.day);
          selectedDate = normalizedDate;
        });
      }

    } catch(e) {
      debugPrint("An error occured $e");
    }
  }

  void createNewChat() async {
    final url = getAPIUrl('chat');
    final String customerId = await getIdFromJWT();
    final currentDate = DateTime.now().toUtc().toIso8601String();

    final newChatPayload = {
      'customer_id': customerId,
      'chat_open': currentDate,
      'status': "open"
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }, 
        body: jsonEncode(newChatPayload)
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chat = data['data'];
        if(!mounted) return;
        await Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chat: chat),));
        getAllChats();
      }
    } catch (err) {
      debugPrint("An error occured $err");
    }
  }

  Map<DateTime, List<dynamic>> _groupChatsByDate(List<dynamic> chats) {
    Map<DateTime, List<dynamic>> groupedEvents = {};

    for(var chat in chats) {
      final rawDate = chat['chat_open'];
      DateTime parsedDate = DateTime.parse(rawDate);
      DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      if(groupedEvents.containsKey(normalizedDate)) {
        groupedEvents[normalizedDate]!.add(chat);
      } else {
        groupedEvents[normalizedDate] = [chat];
      }
    }

    return groupedEvents;
  }

  void navigateToChat(Map<String,dynamic> chat) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatPage(chat: chat))
      );

      getAllChats();
    }

  Widget _buildDreamCard(dynamic chat) {
    final String rawDate = chat['chat_open'];
    DateTime parsedDate = DateTime.parse(rawDate);
    final String date = DateFormat('d MMM yyyy').format(parsedDate);
    final messages = chat['messages'] ?? [];
    final String firstMessage = messages.isNotEmpty ?  messages[0]['content'] : "No messages";

    return GestureDetector(
      onTap: () => navigateToChat(chat),
      child: Container(
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
      ),
    );
  }

  void onDateSelected(DateTime date) {
  // Normalize the date by removing time components
  DateTime normalizedDate = DateTime(date.year, date.month, date.day);
  
  setState(() {
    selectedDate = normalizedDate;
  });
}
  @override
  Widget build(BuildContext context) {
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
                      child: Icon(Icons.account_circle,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),

                SizedBox(
                  height: 320,
                    child: DreamsTable(events: events, onDateSelected: onDateSelected),
                ),
                
                
                SizedBox(height: 20),
                /// Fetch and Display Dream List
                Expanded(
                  child: isLoading ? 
                     Center(
                      child: CircularProgressIndicator(),
                     ) : 
                     selectedDate != null && events[selectedDate] != null
                  ? ListView.builder(
                    itemCount: events[selectedDate]!.length,
                    itemBuilder: (context, index) {
                      final chat = events[selectedDate]![index];
                      return _buildDreamCard(chat);
                    },
                  ) : Center(
                     child: Text("No Chats for this date", style: TextStyle(color: Colors.white70)),
                  )
                ),
              ],
            ),
          ),
        ),
      ),

      /// Floating Button (+) to Add a New Dream
      floatingActionButton: FloatingActionButton(
        onPressed: createNewChat,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
