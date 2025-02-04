import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/constants.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_chat_pro/widgets/display_message_type.dart';
import 'package:swipe_to/swipe_to.dart';

class ContactMessageWidget extends StatelessWidget {
  const ContactMessageWidget({
    super.key,
    required this.message,
    required this.onRightSwipe,
  });
  final MessageModel message;
  final Function() onRightSwipe;

  @override
  Widget build(BuildContext context) {
    final time = formatDate(message.timeSent, [hh, ':', nn, ' ', am]);
    final isReplying = message.repliedTo.isNotEmpty;
    final senderName = message.repliedTo == 'You' ? message.senderName : 'You';

    return SwipeTo(
      onRightSwipe: (details) {
        onRightSwipe();
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            minWidth: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: message.messageType == MessageEnum.text
                      ? const EdgeInsets.fromLTRB(10, 5, 20, 20)
                      : const EdgeInsets.fromLTRB(5, 5, 5, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReplying) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                DisplayMessageType(
                                  message: message.repliedMessage,
                                  type: message.repliedMessageType,
                                  color: Colors.black,
                                  isReply: true,
                                  maxLines: 1,
                                  overFlow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                      DisplayMessageType(
                        message: message.message,
                        type: message.messageType,
                        color: Colors.black,
                        isReply: false,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 10,
                  child: Text(
                    time,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
