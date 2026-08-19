import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.msg,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFD9FDD3)
              : const Color(0xFFF8F3E7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.message,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(msg.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color:
                    isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.status == "seen"
                        ? Icons.done_all
                        : msg.status == "delivered"
                        ? Icons.done_all
                        : Icons.done,
                    size: 16,
                    color: msg.status == "seen"
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}