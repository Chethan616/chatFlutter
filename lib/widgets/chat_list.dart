import 'dart:math';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/models/message_reply_model.dart';
import 'package:flutter_chat_pro/providers/authentication_provider.dart';
import 'package:flutter_chat_pro/providers/chat_provider.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:flutter_chat_pro/widgets/contact_message_widget.dart';
import 'package:flutter_chat_pro/widgets/my_message_widget.dart';
import 'package:flutter_chat_pro/widgets/reactions_dialog.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });
  final String contactUID;
  final String groupId;

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

  void onContextMenuClicked(
      {required String item, required MessageModel message}) {
    switch (item) {
      case 'Reply':

        // set the message reply to true
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );
        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;
      case 'Copy':
        // copy message to clipboard
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message copied to clipboard');
        break;
      case 'Delete':
        // TODO delete message
        // context.read<ChatProvider>().deleteMessage(
        //       userId: uid,
        //       contactUID: widget.contactUID,
        //       messageId: message.messageId,
        //       groupId: widget.groupId,
        //     );
        break;
    }
  }

  showReactionsDialog({required MessageModel message, required String uid}) {
    showDialog(
      context: context,
      builder: (context) => ReactionsDialog(
        uid: uid,
        message: message,
        onReactionsTap: (reaction) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
            print('pressed$reaction');
            // if its a plus reacttion show bottom with emoji keyboard
            if (reaction == '➕') {
              // TODO: show emoji keyboard
              showEmojiContainer();
              // showEmojiKeyboard(
              //     context: context,
              //     onEmojiSelected: (emoji) {
              //         // add emoji to message
              //         context
              //             .read<ChatProvider>()
              //             .addEmojiToMessage(emoji: emoji, message: message);
              //     },
              // );
            } else {
              //     // TODO: add reaction to message
              //     // context
              //     //     .read<ChatProvider>()
              //     //     .addReactionToMessage(reaction: reaction, message: message);
            }
          });
        },
        onContextMenuTap: (item) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pop(context);
            onContextMenuClicked(item: item, message: message);
          });
        },
      ),
    );
  }

  void showEmojiContainer() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            print(emoji);
            //TODO add emoji to message
          },
        ),
      ),
    );
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
              isGroup: widget.groupId,
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                // set message as seen
                if (!element.isSeen && element.senderUID != uid) {
                  print('working');
                  context.read<ChatProvider>().setMessageAsSeen(
                        userId: uid,
                        contactUID: widget.contactUID,
                        messageId: element.messageId,
                        groupId: widget.groupId,
                      );
                }

                // check if we sent the last message
                final isMe = element.senderUID == uid;
                return isMe
                    ? InkWell(
                        onLongPress: () {
                          showReactionsDialog(message: element, uid: uid);
                        },
                        child: Padding(
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
