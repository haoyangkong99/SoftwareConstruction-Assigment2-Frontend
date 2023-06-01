// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:utmletgo/constants/_constants.dart';

class PhotoContainer extends StatelessWidget {
  dynamic onTap, onDelete;
  String url;
  bool isEmpty;
  bool isCover;
  bool isNetworkImage;

  PhotoContainer(
      {Key? key,
      required this.onTap,
      required this.url,
      required this.isCover,
      required this.isNetworkImage,
      required this.isEmpty,
      this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = getMediaQueryHeight(context);
    double width = getMediaQueryWidth(context);
    if (isEmpty) {
      return InkWell(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: width / 4,
            height: height * 0.3,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 40,
                ),
                isCover
                    ? const Text("Cover photo")
                    : const Text("Add more photos")
              ],
            )),
      );
    } else {
      ImageProvider img;
      if (isNetworkImage) {
        img = NetworkImage(url);
      } else {
        img = FileImage(File(url));
      }

      return InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: width / 3,
          height: height * 0.25,
          decoration: BoxDecoration(
              image: DecorationImage(fit: BoxFit.cover, image: img),
              border: Border.all(color: Colors.grey)),
          child: isCover
              ? const Center()
              : Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 26,
                      )),
                ),
        ),
      );
    }
  }
}
