import 'package:murkaverse/pages/home/dream-table.dart';
import 'package:murkaverse/pages/profile/profile-page.dart';
import 'package:murkaverse/providers/chat-provider.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/pages/chat/chat.dart';
import 'package:murkaverse/utils/snackbar.dart';
import 'package:murkaverse/widgets/dreams-card.dart';
import 'package:murkaverse/widgets/updgrade-subscription.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DreamHistory extends StatefulWidget {
  const DreamHistory({super.key});

  @override
  State<DreamHistory> createState() => _DreamHistoryState();
}

class _DreamHistoryState extends State<DreamHistory> {
  DateTime? selectedDate;
  DateTime? currentMonth;
  bool createNewChatLoading = false;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ChatProvider>(context, listen: false).getAllChats();
      }
    });
  }

  // Helper method to get month name from month number
  String _getMonthName(int month) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[month - 1];
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

    bool isPrevChatClosed = chatProvider.chats[0]['status'] != 'closed';

    if (isPrevChatClosed) {
      showErrorSnackBar(context, "Please close the previous chat");
      return;
    }

    setState(() {
      createNewChatLoading = true;
    });

    final chat = await chatProvider.createNewChat();

    if (chat != null) {
      if (!mounted) return;
      setState(() {
        createNewChatLoading = false;
      });
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
      chatProvider.refreshChats();
    }
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
  }

  List<dynamic> getFilteredChats() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chats = chatProvider.chats;
    if (selectedDate != null) {
      return chatProvider.events[selectedDate] ?? [];
    } else {
      DateTime filterMonth = currentMonth ?? DateTime.now();
      return chats.where((chat) {
        DateTime chatDate = DateTime.parse(chat['chat_open']);
        return chatDate.month == filterMonth.month &&
            chatDate.year == filterMonth.year;
      }).toList();
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

  void onMonthChanged(DateTime date) {
    setState(() {
      currentMonth = DateTime(date.year, date.month, 1);
      selectedDate = null;
    });
  }

  bool calculateProfileCompletion(Map<String, dynamic> profile) {
    int totalFields = 5;
    int filledFields = 0;

    if (profile['name'] != null && profile['name'].isNotEmpty) filledFields++;
    if (profile['age'] != null) filledFields++;
    if (profile['gender'] != null && profile['gender'].isNotEmpty) {
      filledFields++;
    }
    if (profile['occupation'] != null && profile['occupation'].isNotEmpty) {
      filledFields++;
    }
    if (profile['cultural_group'] != null &&
        profile['cultural_group'].isNotEmpty) {
      filledFields++;
    }

    return filledFields == totalFields;
  }

  @override
  Widget build(BuildContext context) {
    String monthYearText = currentMonth != null
        ? "${_getMonthName(currentMonth!.month)} ${currentMonth!.year}"
        : "";

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
                  padding: EdgeInsets.fromLTRB(12, 12, 0, 0),
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
                                  final messageLimit =
                                      userProvider.userData?['message_limit'] ??
                                          "null";

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xFF4A1D4A),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE361CF),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                messageLimit.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 20),
                                                child: Text(
                                                  "FILL UP",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "$messageLimit messages are left",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                "Click here to top-up your plan",
                                style: TextStyle(
                                  color: Color(0xFF699DFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Image.asset(
                        'assets/cat2.png',
                        fit: BoxFit.contain,
                      ),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final userData = userProvider.userData;
                    final isProfileCompleted =
                        calculateProfileCompletion(userData ?? {});
                    return Container(
                        child: isProfileCompleted || userProvider.isLoading
                            ? null
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilePage()));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF301530),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5E2FD),
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10)),
                                              ),
                                              child: Icon(
                                                Icons.notifications,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Text(
                                                  "Click here to finish completing your profile information!",
                                                  style: TextStyle(
                                                      color: Color(0xFFF5E2FD),
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.visible,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                  ],
                                ),
                              ));
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Dreams table section
                    DreamsTable(
                      events: Provider.of<ChatProvider>(context, listen: false)
                          .events,
                      onDateSelected: onDateSelected,
                      onMonthChanged: onMonthChanged,
                      createNewChat: createNewChat,
                      createNewChatLoading: createNewChatLoading,
                    ),

                    SizedBox(height: 12),
                    Text(
                      "My Dreams in $monthYearText:",
                      style: TextStyle(
                          color: Color(0xFFF5E2FD),
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),

                    SizedBox(height: 20),

                    // Chat list section
                    Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                      final filteredChats = getFilteredChats();

                      return chatProvider.isLoadingChats
                          ? Center(child: CircularProgressIndicator())
                          : filteredChats.isEmpty
                              ? Center(
                                  child: Text(
                                    selectedDate != null
                                        ? "No dreams for this date"
                                        : "No dreams found for this month",
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
                                  });
                    })
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
