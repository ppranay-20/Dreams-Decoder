import 'package:dreams_decoder/pages/chat/chat.dart';
import 'package:dreams_decoder/pages/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:dreams_decoder/pages/home/dream_history.dart';
import 'package:provider/provider.dart';
import 'package:dreams_decoder/providers/user-provider.dart';
import 'package:dreams_decoder/utils/convert-to-uri.dart';
import 'package:dreams_decoder/utils/getIdFromJWT.dart';
import 'package:dreams_decoder/utils/snackbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Pages to display
  final List<Widget> _pages = [
    DreamHistory(),
    ChatPage(chat: {}, charLimit: 0), // Placeholder for chat page
    Profile(), // Your settings page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF160816),
        selectedItemColor: Color(0xFFE361CF),
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) {
          // If selecting the chat tab (index 1)
          if (index == 1) {
            createNewChat();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Color(0xFF160816),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Dream Chat",
            backgroundColor: Color(0xFF160816),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
            backgroundColor: Color(0xFF160816),
          ),
        ],
      ),
    );
  }

  void createNewChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageLimit = userProvider.userData?['message_limit'] as int? ?? 0;
    final charLimit = userProvider.userData?['character_limit'] as int? ?? 0;
    final isLoading = userProvider.isLoading;

    if (isLoading) return;

    if (messageLimit <= 0) {
      showErrorSnackBar(
          context, "You don't have messages left. Please buy more messages.");
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

        // Navigate to the chat page with the new chat
        setState(() {
          _currentIndex = 1; // Set to chat tab
          _pages[1] = ChatPage(
              chat: chat, messageLimit: messageLimit, charLimit: charLimit);
        });
      }
    } catch (err) {
      debugPrint("An error occurred: $err");
      showErrorSnackBar(
          context, "Failed to create a new chat. Please try again.");
    }
  }
}
