import 'package:flutter/material.dart';
import 'package:utmletgo/constants/_constants.dart';

class SubTitleHeader extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final Color? color;
  const SubTitleHeader(
      {super.key,
      required this.text,
      this.trailing,
      this.color = kPrimaryColor});

  @override
  Widget build(BuildContext context) {
    List<Widget> row = [
      Container(
          width: getMediaQueryWidth(context) * 0.02,
          height: getMediaQueryHeight(context) * 0.03,
          color: color),
      const SizedBox(width: 20),
      Expanded(
          child: Text(
        text,
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        maxLines: 2,
      )),
    ];
    if (trailing != null) {
      row.add(trailing!);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: row,
      ),
    );
  }
}
