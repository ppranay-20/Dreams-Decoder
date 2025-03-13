import 'dart:convert';

import 'package:murkaverse/utils/convert-to-uri.dart';
import 'package:murkaverse/utils/getIdFromJWT.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentChat;
  bool _isLoading = false;

  Map<String, dynamic>? get currentChat => _currentChat;
  bool get isLoading => _isLoading;

  bool get hasActiveChat => _currentChat != null && _currentChat!.isNotEmpty;

  void setCurrentChat(Map<String, dynamic> chat) {
    _currentChat = chat;
    notifyListeners();
  }

  void clearCurrentChat() {
    _currentChat = null;
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
