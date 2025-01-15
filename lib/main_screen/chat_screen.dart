import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/widgets/chat_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // get arguments passed from previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // get the contactUID from the arguments
    final contactUID = arguments[Constants.contactUID];
    // get the contactName from the arguments
    final contactName = arguments[Constants.contactName];
    // get the contactImage from the arguments
    final contactImage = arguments[Constants.contactImage];
    // get the groupID from the arguments
    final groupID = arguments[Constants.groupID];
    // check if the groupID is empty - then its a chat with a friend else its a group chat
    final isGroupChat = groupID.isNotEmpty ? true : false;
    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactId: contactUID),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('message $index'),
                ); // ListTile
              },
            ), // ListView.builder
          ), // Expanded
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Type a message',
              suffixIcon: Icon(Icons.send),
            ), // InputDecoration
          ), // TextFormField
        ],
      ),
    );
  }
}
