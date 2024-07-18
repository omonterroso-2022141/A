import 'package:flutter/material.dart';

import '../domian/message.dart';

class ChatProviders extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController();
  static final Color defaultColor = Color(0xFF53C4A6);

  List<Message> messageList = [];

  Future<void> addMessage(String text, String sender) async {
    final newMessage = Message(
        text: text,
        fromWho: sender == 'Me' ? FromWho.me : FromWho.hers,
        color: defaultColor);
    messageList.add(newMessage);

    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }
}
