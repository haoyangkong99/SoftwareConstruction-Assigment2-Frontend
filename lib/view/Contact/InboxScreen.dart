import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Contact/ConversationCard.dart';
import 'package:utmletgo/viewmodel/InboxViewModel.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    List<Chat> buyingList = [];
    List<Chat> sellingList = [];
    List<Chat> chatList = [];
    List<User> userList = [];
    List<Item> itemList = [];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: basicAppBar(
          height: getMediaQueryHeight(context),
          title: const Text(
            "Inbox",
            // style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorColor: Colors.white,
              indicatorWeight: 4,
              tabs: [
                Tab(
                  child: Text(
                    "Buying",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                    child: Text(
                  "Selling",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ))
              ]),
        ),
        body: ViewModelBuilder<InboxViewModel>.reactive(
          viewModelBuilder: () => InboxViewModel(),
          builder: (context, model, child) {
            if (model.dataReady('chatList') &&
                model.dataReady('currentUser') &&
                model.dataReady('userList') &&
                model.dataReady('itemList')) {
              User currentUser = model.dataMap!['currentUser'];
              chatList = model.dataMap!['chatList'];
              userList = model.dataMap!['userList'];
              itemList = model.dataMap!['itemList'];

              List<String> involvedItemGuids =
                  chatList.map((e) => e.itemGuid).toList();
              Set<String> involvedUserGuids = {};
              chatList.forEach((element) async {
                involvedUserGuids.addAll(element.userGuids);
              });
              itemList = itemList
                  .where((element) => involvedItemGuids.contains(element.guid))
                  .toList();

              userList = userList
                  .where((element) => involvedUserGuids.contains(element.guid))
                  .toList();
              buyingList = chatList
                  .where(
                      (chat) => !currentUser.itemLink.contains(chat.itemGuid))
                  .toList();
              sellingList = chatList
                  .where((chat) => currentUser.itemLink.contains(chat.itemGuid))
                  .toList();
              return TabBarView(children: [
                buyingList.isEmpty
                    ? Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/No conversation icon seller.png'))),
                      )
                    : ListView.builder(
                        itemCount: buyingList.length,
                        itemBuilder: (context, index) {
                          Item item = itemList
                              .where((element) =>
                                  element.guid == buyingList[index].itemGuid)
                              .first;
                          User seller = userList
                              .where((element) => element.itemLink
                                  .contains(buyingList[index].itemGuid))
                              .first;
                          return ConversationCard(
                              img: item.coverImage,
                              name: seller.name,
                              subtitle: Text(
                                item.title,
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.red),
                              ),
                              ontap: () {
                                model.navigateToChatScreen(
                                    buyingList[index].guid,
                                    seller.guid,
                                    item.guid);
                              });
                        }),
                sellingList.isEmpty
                    ? Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    'assets/images/No conversation icon buyer.png'))),
                      )
                    : ListView.builder(
                        itemCount: sellingList.length,
                        itemBuilder: (context, index) {
                          Item item = itemList
                              .where((element) =>
                                  element.guid == sellingList[index].itemGuid)
                              .elementAt(0);
                          User buyer = userList
                              .where((element) => !element.itemLink
                                  .contains(sellingList[index].itemGuid))
                              .elementAt(0);
                          return ConversationCard(
                              img: item.coverImage,
                              name: buyer.name,
                              subtitle: Text(
                                item.title,
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.red),
                              ),
                              ontap: () {
                                model.navigateToChatScreen(
                                    sellingList[index].guid,
                                    buyer.guid,
                                    item.guid);
                              });
                        }),
              ]);
            } else {
              return const Center(
                  child: CircularProgressIndicator(
                color: kPrimaryColor,
              ));
            }
          },
        ),
      ),
    );
  }
}
