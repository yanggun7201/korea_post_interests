import 'package:flutter/material.dart';
import 'package:korea_post_interests/models/Message.dart';

class MessageProvider extends ChangeNotifier {
  final List<Message> messages = [];

  void addMessage(Message message) {
    messages.add(message);
    notifyListeners();
  }

  void removeMessage(Message message) {
    messages.remove(message);
    notifyListeners();
  }

  void clearAllMessages() {
    messages.clear();
    notifyListeners();
  }
}
