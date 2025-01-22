import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';

class ReactionsDialog extends StatefulWidget {
  const ReactionsDialog({
    super.key,
    required this.uid,
    required this.message,
    required this.onReactionsTap,
    required this.onContextMenuTap,
  });

  final String uid;
  final MessageModel message;
  final Function(String) onReactionsTap;
  final Function(String) onContextMenuTap;

  @override
  State<ReactionsDialog> createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  @override
  Widget build(BuildContext context) {
    final isMyMessage = widget.uid == widget.message.senderUID;
    return Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    for (final reaction in reactions)
                      InkWell(
                        onTap: () {
                          widget.onReactionsTap(reaction);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            reaction,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isMyMessage
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.message.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (final menu in contextMenu)
                        InkWell(
                          onTap: () {
                            widget.onContextMenuTap(menu);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  menu,
                                  style: const TextStyle(fontSize: 20),
                                ), // Text
                                Icon(menu == 'Reply'
                                    ? Icons.reply
                                    : menu == 'Copy'
                                        ? Icons.copy
                                        : Icons.delete),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
