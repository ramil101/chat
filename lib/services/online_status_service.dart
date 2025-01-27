import 'package:flutter/material.dart';
import 'package:chat/services/auth/chat/chat_service.dart';

class OnlineStatusService with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  bool _isInitialized = false;

  void initialize() {
    if (!_isInitialized) {
      WidgetsBinding.instance.addObserver(this);
      _updateOnlineStatus(true);
      _isInitialized = true;
    }
  }

  void dispose() {
    if (_isInitialized) {
      _updateOnlineStatus(false);
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _updateOnlineStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _updateOnlineStatus(false);
        break;
      default:
        break;
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      await _chatService.updateOnlineStatus(isOnline);
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}
