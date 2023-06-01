import 'package:flutter/material.dart';
import 'package:utmletgo/constants/size_config.dart';

class ConversationCard extends StatelessWidget {
  final String img, name;
  Widget subtitle;

  final ontap;
  ConversationCard({
    Key? key,
    required this.img,
    required this.name,
    required this.subtitle,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = getMediaQueryWidth(context);
    double height = getMediaQueryHeight(context);
    return InkWell(
      onTap: ontap,
      child: Card(
        elevation: 5,
        child: Container(
          height: getMediaQueryHeight(context) * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.03,
                      right: width * 0.03,
                    ),
                    child: Container(
                      height: height * 0.13,
                      width: width * 0.35,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          img,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10.0),
                      subtitle,
                      const SizedBox(height: 10.0),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
