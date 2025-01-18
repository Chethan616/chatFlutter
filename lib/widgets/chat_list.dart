import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/message_reply_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/contact_message_widget.dart';
import 'package:flutter_chat_pro/widgets/my_message_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupID,
  });
  final String contactUID;
  final String groupID;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  // scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // current user id
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return GestureDetector(
      onVerticalDragDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: StreamBuilder<List<MessageModel>>(
        stream: context.read<ChatProvider>().getMessagesStream(
              userId: uid,
              contactUID: widget.contactUID,
              isGroup: widget.groupID,
            ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Start a convo',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            );
          }

          // automatically scroll to the bottom on new message
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          });
          if (snapshot.hasData) {
            final messagesList = snapshot.data!;
            return GroupedListView<dynamic, DateTime>(
              reverse: true,
              controller: _scrollController,
              elements: messagesList,
              groupBy: (element) {
                return DateTime(
                  element.timeSent!.year,
                  element.timeSent!.month,
                  element.timeSent!.day,
                );
              },
              groupHeaderBuilder: (dynamic groupByValue) =>
                  SizedBox(height: 40, child: buildDateTime(groupByValue)),
              itemBuilder: (context, dynamic element) {
                // check if we sent the last message
                final isMe = element.senderUID == uid;
                return isMe
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: MyMessageWidget(
                          message: element,
                          onRightSwipe: () {
                            // set the message reply to true
                            final messageReply = MessageReplyModel(
                              message: element.message,
                              senderUID: element.senderUID,
                              senderName: element.senderName,
                              senderImage: element.senderImage,
                              messageType: element.messageType,
                              isMe: isMe,
                            );
                            context
                                .read<ChatProvider>()
                                .setMessageReplyModel(messageReply);
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: ContactMessageWidget(
                            message: element,
                            onRightSwipe: () {
                              // set the message reply to true
                              final messageReply = MessageReplyModel(
                                message: element.message,
                                senderUID: element.senderUID,
                                senderName: element.senderName,
                                senderImage: element.senderImage,
                                messageType: element.messageType,
                                isMe: isMe,
                              );
                              context
                                  .read<ChatProvider>()
                                  .setMessageReplyModel(messageReply);
                            }),
                      );
              },
              groupComparator: (value1, value2) => value2.compareTo(value1),
              itemComparator: (item1, item2) {
                var firstItem = item1.timeSent;

                var secondItem = item2.timeSent;
                return secondItem!.compareTo(firstItem!);
              },
              useStickyGroupSeparators: true,
              floatingHeader: true,
              order: GroupedListOrder.ASC,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
