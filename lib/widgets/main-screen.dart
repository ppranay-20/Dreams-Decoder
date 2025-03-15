import 'package:murkaverse/pages/chat/chat.dart';
import 'package:murkaverse/pages/profile/profile.dart';
import 'package:murkaverse/providers/chat-provider.dart';
import 'package:flutter/material.dart';
import 'package:murkaverse/pages/home/dream-history.dart';
import 'package:provider/provider.dart';
import 'package:murkaverse/providers/user-provider.dart';
import 'package:murkaverse/utils/snackbar.dart';

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
    Container(),
    Profile(), // Your settings page
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).getUserData();
    });
  }

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
            _handleChatTab();
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

  void _handleChatTab() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!chatProvider.hasActiveChat) {
      showErrorSnackBar(context, "Select a dream or add new dream");
      return;
    }

    final chat = chatProvider.currentChat;
    final messageLimit = userProvider.userData?['message_limit'] as int;
    final charLimit = userProvider.userData?['character_limit'] as int;

    if (messageLimit <= 0) {
      showErrorSnackBar(
          context, "You don't have messages left. Please buy more messages.");
      return;
    }

    if (chatProvider.isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chat: chat!,
          messageLimit: messageLimit,
          charLimit: charLimit,
        ),
      ),
    );
  }
}
