import 'dart:convert';

import 'package:dreams_decoder/pages/home/dream-table.dart';
import 'package:dreams_decoder/pages/profile/profile.dart';
import 'package:dreams_decoder/providers/user-provider.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:dreams_decoder/pages/chat/chat.dart';
import 'package:dreams_decoder/utils/getUserData.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'package:dreams_decoder/widgets/dreams-card.dart';
import 'package:dreams_decoder/widgets/updgrade-subscription.dart';
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
  DateTime? startDate;
  DateTime? endDate;
  bool isDateRangeFilterActive = false;
  double profileCompletion = 0.0;

  @override
  void initState() {
    super.initState();
    getAllChats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).getUserData();
    });
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
    final messageLimit = userProvider.userData?['message_limit'] as int;
    final charLimit = userProvider.userData?['character_limit'] as int;
    final isLoading = userProvider.isLoading;

    if (isLoading) return;

    if (messageLimit <= 0) {
      showErrorSnackBar(
          context, "You don't have message left, Please buy more messages");
      return;
    }

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
              builder: (context) => ChatPage(chat: chat, messageLimit: messageLimit, charLimit: charLimit),
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageLimit = userProvider.userData?['message_limit'] as int;
    final charLimit = userProvider.userData?['character_limit'] as int;
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ChatPage(chat: chat, messageLimit: messageLimit, charLimit: charLimit,)));
    getAllChats();
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
    debugPrint(
        "Date range filter active: ${startDate!.toString()} to ${endDate!.toString()}");
  }

  List<dynamic> getFilteredChats() {
    if (selectedDate != null) {
      return events[selectedDate] ?? [];
    } else if (isDateRangeFilterActive &&
        startDate != null &&
        endDate != null) {
      return chats.where((chat) {
        final rawDate = chat['chat_open'];
        DateTime parsedDate = DateTime.parse(rawDate);
        DateTime normalizedDate =
            DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        // Ensure the selected range is correctly applied
        return normalizedDate.isAtSameMomentAs(startDate!) ||
            (normalizedDate.isAfter(startDate!) &&
                normalizedDate.isBefore(endDate!)) ||
            normalizedDate.isAtSameMomentAs(endDate!);
      }).toList();
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
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      "https://s3-alpha-sig.figma.com/img/add9/4065/46d082f4367c08f6cb77204e0e16b900?Expires=1742169600&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=CDiP-4M6iPbRRiU0nm5VK3h0VHMWU42HKbfbExcR4P1HC9R886DQpl1rEdTV5oe3~81dgr2V-z2szRPIztQSHZ09C7LWSNR7yBwK9exDCd6UvIeivxXQk-grUZAzptU6LOjZlWxuRHV8KOo7MGj9unJAbZY7586gjD6xQ8NLWoxL1MApn7QQq7PgikbeQ0nypgSCwOQOWfZpXZzbL7PKf4dzbgW7KbsIgeIa4Xw3nh49siXKZPYmYMSKUsTdC7gbF3WNfhIh3Bf5zsx7AWgXWz4jLuAkMa-LB9PoBsYaeIFGU98xoC1kJqqyj8DX4PveGMfhJsGt-NwM61qY8Uqdkw__",
                      fit: BoxFit.contain,
                      height: 50,
                      width: 200,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Profile()));
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white),
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.person, // Profile icon
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                          12), // Add some padding for better appearance
                      decoration: BoxDecoration(
                        color: Colors.white12, // Semi-transparent background
                        borderRadius: BorderRadius.circular(
                            10), // Optional rounded corners
                      ),
                      child: Column(
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
                              color: Colors.white,
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
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 150,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Image.asset(
                        'assets/murka.png',
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      // Dreams table section
                      DreamsTable(
                        events: events,
                        onDateSelected: onDateSelected,
                        clearDateSelected: clearDateSelected,
                        onDateRangeSelected: onDateRangeSelected,
                      ),

                      SizedBox(height: 20),

                      // Chat list section
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : filteredChats.isEmpty
                              ? Center(
                                  child: Text(
                                    isDateRangeFilterActive
                                        ? "No dreams found within the selected date range"
                                        : selectedDate != null
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
      ),
    );
  }
}
