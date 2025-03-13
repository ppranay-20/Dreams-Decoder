import 'dart:convert';

import 'package:murkaverse/pages/home/dream-table.dart';
import 'package:murkaverse/providers/chat-provider.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:murkaverse/pages/chat/chat.dart';
import 'package:murkaverse/utils/getUserData.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:murkaverse/widgets/dreams-card.dart';
import 'package:murkaverse/widgets/updgrade-subscription.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

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
  double profileCompletion = 0.0;

  @override
  void initState() {
    super.initState();
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
        List<dynamic> sortedChats = List.from(data['data']);
        sortedChats.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA);
        });

        setState(() {
          isLoading = false;
          chats = sortedChats;
          events = _groupChatsByDate(sortedChats);
        });
      }
    } catch (e) {
      debugPrint("An error occured $e");
    }
  }

  void createNewChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final messageLimit = userProvider.userData?['message_limit'] as int;
    final charLimit = userProvider.userData?['character_limit'] as int;
    final isLoading = userProvider.isLoading;

    if (isLoading) return;

    if (messageLimit <= 0) {
      showErrorSnackBar(
          context, "You don't have message left, Please buy more messages");
      return;
    }

    final chat = await chatProvider.createNewChat();

    if (chat != null) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chat: chat,
            messageLimit: messageLimit,
            charLimit: charLimit,
          ),
        ),
      );
      getAllChats();
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final messageLimit = userProvider.userData?['message_limit'] as int;
    final charLimit = userProvider.userData?['character_limit'] as int;

    // Set the selected chat as the current chat in the provider
    chatProvider.setCurrentChat(chat);

    // Navigate to the chat page
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chat: chat,
            messageLimit: messageLimit,
            charLimit: charLimit,
          ),
        ));

    // Refresh the chat list after returning
    getAllChats();
  }

  List<dynamic> getFilteredChats() {
    if (selectedDate != null) {
      return events[selectedDate] ?? [];
    } else {
      return chats;
    }
  }

  Future<void> getProfileCompletion() async {
    try {
      final userData = await getUserData();
      setState(() {
        profileCompletion = calculateProfileCompletion(userData);
      });
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    }
  }

  void onDateSelected(DateTime date) {
    // Check if this is our special signal to clear the date selection
    if (date.year == 0) {
      setState(() {
        selectedDate = null; // Set to null instead of using the DateTime(0)
      });
    } else {
      DateTime normalizedDate = DateTime(date.year, date.month, date.day);
      setState(() {
        selectedDate = normalizedDate;
      });
    }
  }

  double calculateProfileCompletion(Map<String, dynamic> profile) {
    int totalFields = 5;
    int filledFields = 0;

    if (profile['name'] != null && profile['name'].isNotEmpty) filledFields++;
    if (profile['age'] != null) filledFields++;
    if (profile['gender'] != null && profile['gender'].isNotEmpty)
      filledFields++;
    if (profile['occupation'] != null && profile['occupation'].isNotEmpty)
      filledFields++;
    if (profile['cultural_group'] != null &&
        profile['cultural_group'].isNotEmpty) filledFields++;

    return filledFields / totalFields;
  }

  @override
  Widget build(BuildContext context) {
    final filteredChats = getFilteredChats();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6),
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
                height: 50,
                width: 200,
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "The hidden potential in dreams.",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFF5E2FD),
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 24),
              Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF301530), // Semi-transparent background
                    borderRadius:
                        BorderRadius.circular(10), // Optional rounded corners
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Consumer<UserProvider>(
                                builder: (context, userProvider, child) {
                                  final messageLimit = userProvider
                                          .userData?['message_limit']
                                          .toString() ??
                                      "null";

                                  return Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Messages left: $messageLimit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    color: Colors.white30,
                                    shape: BoxShape.circle),
                                child: GestureDetector(
                                  onTap: () => createNewChat(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 6.0),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "It looks like you're nearing the end\nof your free monthly dream credits.",
                            style: TextStyle(
                              color: Color(0xFFF5E2FD),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              showPaymentDialog(context);
                            },
                            child: Text(
                              "Click here to top-up your plan",
                              style: TextStyle(
                                color: Color(0xFF699DFF),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Image.asset(
                        'assets/cat2.png',
                        width: 150,
                        height: 120,
                      ),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Dreams table section
                    DreamsTable(
                      events: events,
                      onDateSelected: onDateSelected,
                    ),

                    SizedBox(height: 20),

                    // Chat list section
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredChats.isEmpty
                            ? Center(
                                child: Text(
                                  selectedDate != null
                                      ? "No dreams for this date"
                                      : "No dreams found",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredChats.length,
                                itemBuilder: (context, index) {
                                  final chat = filteredChats[index];
                                  return DreamCard(
                                      chat: chat,
                                      navigateToChat: navigateToChat);
                                },
                              ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
