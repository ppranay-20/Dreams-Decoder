import 'dart:convert';

import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:murkaverse/utils/group-chats-by-date.dart';

class ChatProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentChat;
  bool _isLoading = false;
  List<Map<String, dynamic>> _chats = [];
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoadingChats = false;
  bool _hasChatsLoaded = false;

  Map<String, dynamic>? get currentChat => _currentChat;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get chats => _chats;
  Map<DateTime, List<dynamic>> get events => _events;
  bool get isLoadingChats => _isLoadingChats;
  bool get hasChatsLoaded => _hasChatsLoaded;
  bool get hasActiveChat => _currentChat != null && _currentChat!.isNotEmpty;

  void setCurrentChat(Map<String, dynamic> chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void clearCurrentChat() {
    _currentChat = null;
    notifyListeners();
  }

  Future<void> getAllChats() async {
    if (_hasChatsLoaded) return;
    _isLoadingChats = true;
    notifyListeners();

    try {
      final String customerId = await getIdFromJWT();
      final url = getAPIUrl('chat/user/$customerId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> sortedChats = List.from(data['data'] ?? []);

        // Sort chats by date (newest first)
        sortedChats.sort((a, b) {
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA);
        });

        _chats = List<Map<String, dynamic>>.from(sortedChats);
        _events = groupChatsByDate(_chats);
        _hasChatsLoaded = true;
      } else {
        debugPrint("Failed to load chats: ${response.statusCode}");
      }
    } catch (err) {
      debugPrint("An error occurred loading chats: $err");
    } finally {
      _isLoadingChats = false;
      notifyListeners();
    }
  }

  void refreshChats() {
    _hasChatsLoaded = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createNewChat() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = getAPIUrl('chat');
      final String customerId = await getIdFromJWT();
      final currentDate = DateTime.now().toUtc().toIso8601String();

      final newChatPayload = {
        'customer_id': customerId,
        'chat_open': currentDate,
        'status': "open"
      };

      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(newChatPayload));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chat = data['data'];
        setCurrentChat(chat);
        _isLoading = false;
        notifyListeners();
        return chat;
      } else {
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (err) {
      debugPrint("An error occurred: $err");
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // End the current chat
  Future<Map<String, dynamic>?> endCurrentChat() async {
    if (_currentChat == null || _currentChat!.isEmpty) {
      return null;
    }

    try {
      final chatId = _currentChat!['id'];
      final url = getAPIUrl('chat/end-chat/$chatId');

      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode({'status': 'closed'}));

      if (response.statusCode == 200) {
        // Update the local chat status
        _currentChat!['status'] = 'closed';
        notifyListeners();
        return _currentChat;
      }
      return null;
    } catch (err) {
      debugPrint("An error occurred ending chat: $err");
      return null;
    }
  }
}
