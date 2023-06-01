import 'package:flutter/material.dart';
import 'package:utmletgo/constants/_constants.dart';

class MessageStatusDot extends StatelessWidget {
  final bool isRead;

  const MessageStatusDot({Key? key, required this.isRead}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: getMediaQueryWidth(context) * 0.1 / 2),
      height: 15,
      width: 12,
      decoration: BoxDecoration(
        color: isRead
            ? kPrimaryColor
            : Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.done,
        size: 11,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
