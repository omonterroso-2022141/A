import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_providers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final chatProvider = Provider.of<ChatProviders>(context, listen: false);
      chatProvider.addMessage(_messageController.text, 'Me');
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Chat', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProviders>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  reverse: true,
                  itemCount: chatProvider.messageList.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messageList[index];
                    return ListTile(
                      title: Text(
                        message.text,
                        style: const TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        '${message.sender} • ${message.timestamp.hour}:${message.timestamp.minute}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Message class definition
class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});
}

// ChatProviders class definition
class ChatProviders with ChangeNotifier {
  List<Message> _messageList = [];

  List<Message> get messageList => _messageList;

  void addMessage(String text, String sender) {
    final newMessage = Message(
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
    );
    _messageList.insert(0, newMessage);
    notifyListeners();
  }
}
