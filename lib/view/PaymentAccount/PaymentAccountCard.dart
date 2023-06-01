import 'package:flutter/material.dart';

import 'package:utmletgo/constants/_constants.dart';

class BankAccountCard extends StatelessWidget {
  final String name, accountNo, bankName;
  final Color color;
  final bool deletable;
  final dynamic onTap;
  const BankAccountCard(
      {super.key,
      required this.name,
      required this.accountNo,
      required this.bankName,
      required this.color,
      this.deletable = true,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = getMediaQueryWidth(context);
    return InkWell(
      child: Container(
        width: width * 0.25,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
            color: deletable ? color : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            !deletable
                ? const Center()
                : Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: onTap,
                      child: const Icon(
                        Icons.cancel,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
            Text(
                !deletable
                    ? 'Add New\nBank Account'
                    : '$name\n$accountNo\n${bankName.replaceAll(RegExp(r'_'), ' ')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: deletable ? Colors.white : Colors.black,
                  fontSize: 14.0,
                ))
          ],
        ),
      ),
    );
  }
}
