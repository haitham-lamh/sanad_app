import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    this.createdAt,
  });
  final String text;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final day = createdAt ?? DateTime.now();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xff716CC7),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20, right: 6),
              child: Text(
                text,
                style: TextStyle(
                    color: Color(0xffFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Text(
                ' ${DateFormat('HH:mm').format(day)}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubbleForFrind extends StatelessWidget {
  const ChatBubbleForFrind({
    super.key,
    required this.text,
    this.createdAt,
  });
  final String text;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final day = createdAt ?? DateTime.now();
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xff555B71),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20, left: 6),
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                ' ${DateFormat('HH:mm').format(day)}',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
