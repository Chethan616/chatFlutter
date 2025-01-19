import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/widgets/bottom_chat_field.dart';
import 'package:flutter_chat_pro/widgets/chat_app_bar.dart';
import 'package:flutter_chat_pro/widgets/chat_list.dart';

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
    final groupID = arguments[Constants.groupId];
    // check if the groupID is empty - then its a chat with a friend else its a group chat
    final isGroupChat = groupID.isNotEmpty ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                contactUID: contactUID,
                groupId: groupID,
              ),
            ),
            BottomChatField(
                contactUID: contactUID,
                contactName: contactName,
                contactImage: contactImage,
                groupID: groupID)
          ],
        ),
      ),
    );
  }
}
