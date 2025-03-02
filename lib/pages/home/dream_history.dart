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
    DateTime? startDate;
  DateTime? endDate;
  bool isDateRangeFilterActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllChats();
  }

  void getAllChats() async {
    final customerId = await getIdFromJWT();
    try {
      final url = getAPIUrl('chat/user/$customerId');

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          isLoading = false;
          chats = data['data'];
          events = _groupChatsByDate(chats);
        });
      }
    } catch (e) {
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
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(newChatPayload));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chat = data['data'];
        if (!mounted) return;
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(chat: chat),
            ));
        getAllChats();
      }
    } catch (err) {
      debugPrint("An error occured $err");
    }
  }

  Map<DateTime, List<dynamic>> _groupChatsByDate(List<dynamic> chats) {
    Map<DateTime, List<dynamic>> groupedEvents = {};

    for (var chat in chats) {
      final rawDate = chat['chat_open'];
      DateTime parsedDate = DateTime.parse(rawDate);
      DateTime normalizedDate =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      if (groupedEvents.containsKey(normalizedDate)) {
        groupedEvents[normalizedDate]!.add(chat);
      } else {
        groupedEvents[normalizedDate] = [chat];
      }
    }

    return groupedEvents;
  }

  void navigateToChat(Map<String, dynamic> chat) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatPage(chat: chat)));

    getAllChats();
  }

  Widget _buildDreamCard(dynamic chat) {
    final String rawDate = chat['chat_open'];
    DateTime parsedDate = DateTime.parse(rawDate);
    final String date = DateFormat('d MMM yyyy').format(parsedDate);
    final messages = chat['messages'] ?? [];
    final String firstMessage =
        messages.isNotEmpty ? messages[0]['content'] : "No messages";

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
            isDateRangeFilterActive = false;
      startDate = null;
      endDate = null;
    });
  }

  void clearDateSelected() {
    setState(() {
      selectedDate = null;
      isDateRangeFilterActive = false;
      startDate = null;
      endDate = null;
    });
  }

     void onDateRangeSelected(DateTime start, DateTime end) {
    setState(() {
      // Normalize the dates by removing time components
      startDate = DateTime(start.year, start.month, start.day);
      endDate = DateTime(end.year, end.month, end.day);
      isDateRangeFilterActive = true;
      // Reset single date selection
      selectedDate = null;
    });
    
    // Debug log to verify dates
    debugPrint("Date range filter active: ${startDate!.toString()} to ${endDate!.toString()}");
  }

   List<dynamic> getFilteredChats() {
  if (selectedDate != null) {
    return events[selectedDate] ?? [];
  } else if (isDateRangeFilterActive && startDate != null && endDate != null) {
    return chats.where((chat) {
      final rawDate = chat['chat_open'];
      DateTime parsedDate = DateTime.parse(rawDate);
      DateTime normalizedDate = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      
      // Ensure the selected range is correctly applied
      return normalizedDate.isAtSameMomentAs(startDate!) ||
             (normalizedDate.isAfter(startDate!) && normalizedDate.isBefore(endDate!)) ||
             normalizedDate.isAtSameMomentAs(endDate!);
    }).toList();
  } else {
    return chats;
  }
}

  @override
  Widget build(BuildContext context) {
    final filteredChats = getFilteredChats();
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
                  height: 365,
                  child: DreamsTable(
                      events: events, onDateSelected: onDateSelected, clearDateSelected: clearDateSelected, onDateRangeSelected: onDateRangeSelected,),
                ),

                SizedBox(height: 20),

                /// Fetch and Display Dream List
               Expanded(
                  child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : filteredChats.isNotEmpty
                      ? ListView.builder(
                          itemCount: filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = filteredChats[index];
                            return _buildDreamCard(chat);
                          })
                      : Center(
                          child: Text(
                            isDateRangeFilterActive 
                              ? "No dreams found within the selected date range" 
                              : selectedDate != null 
                                ? "No dreams for this date"
                                : "No dreams found",
                            style: TextStyle(color: Colors.white70)
                          ),
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
