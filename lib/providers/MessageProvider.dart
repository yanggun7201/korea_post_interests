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

  void clickMessage(Message message) {
    var newMessages = messages.map((e) {
      if (e.postId == message.postId) {
        return message.copyWith(isClicked: true);
      }
      return e;
    }).toList();

    messages.clear();
    messages.addAll(newMessages);
    notifyListeners();
  }
}
