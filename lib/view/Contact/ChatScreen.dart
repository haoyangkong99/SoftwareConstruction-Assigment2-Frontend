import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/DateTimeConversion.dart';
import 'package:utmletgo/shared/Exception.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Contact/_contact.dart';
import 'package:utmletgo/view/Marketplace/UserProfileScreen.dart';

import 'package:utmletgo/viewmodel/_viewmodel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return ViewModelBuilder<ChatViewModel>.reactive(
        viewModelBuilder: () => ChatViewModel(),
        builder: (context, model, child) {
          List<Message> messageList = model.chat.messages;
          _scrollController.addListener(() async {
            if (_scrollController.position.atEdge) {
              if (_scrollController.position.pixels != 0) {
                if (messageList.isNotEmpty &&
                    messageList.last.readyBy.length < 2 &&
                    messageList.last.readyBy.isEmpty &&
                    messageList.last.senderGuid != model.sender.guid) {
                  for (var element in messageList) {
                    if (element.readyBy.isEmpty) {
                      element.readyBy = model.chat.userGuids
                          .where((guid) => guid != element.senderGuid)
                          .first;
                    }
                  }

                  await model.updateMessageStatus(model.chat.guid, messageList);
                }
              }
            }
          });

          return Scaffold(
            appBar: AppBar(
              backgroundColor: kPrimaryColor,
              title: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                              userGuid: model.receiver.guid)));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.receiver.profilePicture),
                    ),
                    const SizedBox(width: 20 * 0.75),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.receiver.name,
                            style: const TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () async {
                      await model
                          .launchWhatsapp(model.receiver.contact)
                          .onError<GeneralException>((error, stackTrace) =>
                              showGeneralExceptionErrorDialogBox(
                                  context, error));
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      size: 20,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () async {
                      await model.launchPhone(model.receiver.contact);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.phone,
                      size: 20,
                      color: Colors.white,
                    )),
              ],
            ),
            body: Column(
              children: [
                Card(
                  elevation: 6,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.05, height * 0.005,
                        width * 0.05, height * 0.005),
                    child: Row(
                      children: [
                        SizedBox(
                            height: height * 0.1,
                            width: width * 0.2,
                            child: Image.network(model.item.coverImage)),
                        SizedBox(
                          width: width * 0.03,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              model.item.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              "RM ${model.item.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 12.0, color: Colors.black),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GroupedListView<Message, String>(
                    controller: _scrollController,
                    elements: messageList,
                    groupBy: (Message message) => DateFormat('dd/MM/yy')
                        .format(convertToDateTime(message.timeSent)),
                    groupSeparatorBuilder: (String groupByValue) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(groupByValue),
                        ),
                      );
                    },
                    itemBuilder: (context, Message message) => ChatMessage(
                      message: message,
                      isSender: message.senderGuid == model.sender.guid,
                      receiver: model.receiver,
                    ),
                  ),
                )),
                const SafeArea(child: ChatInputFields())
              ],
            ),
            // ),
          );
        });
  }
}
