import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Contact/_contact.dart';
import 'package:utmletgo/viewmodel/ViewOfferViewModel.dart';

class ViewOfferScreen extends StatelessWidget {
  const ViewOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar(
        automaticallyImplyLeading: true,
        height: getMediaQueryHeight(context),
        title: const Text(
          "View Offer",
          // style: TextStyle(color: Colors.white),
        ),
      ),
      body: ViewModelBuilder<ViewOfferViewModel>.reactive(
        viewModelBuilder: () => ViewOfferViewModel(),
        builder: (context, model, child) {
          if (model.dataReady('user') && model.dataReady('chat')) {
            List<User> buyerList = model.dataMap!['user'];
            List<Chat> chatList = model.dataMap!['chat'];
            return chatList.isEmpty
                ? Center(
                    child: Container(
                      width: getMediaQueryWidth(context) * 0.7,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage('assets/images/No offer.png'))),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      User buyer = buyerList
                          .where((element) =>
                              chatList[index]
                                  .userGuids
                                  .contains(element.guid) &&
                              !element.itemLink
                                  .contains(chatList[index].itemGuid))
                          .first;
                      return ConversationCard(
                          img: buyer.profilePicture,
                          name: buyer.name,
                          subtitle: Row(
                            children: [
                              RatingBar.readOnly(
                                size: 20,
                                isHalfAllowed: true,
                                halfFilledIcon: Icons.star_half,
                                filledIcon: Icons.star,
                                emptyIcon: Icons.star_border,
                                initialRating: buyer.reviewsLink.averageRating,
                              ),
                              SizedBox(
                                width: getMediaQueryWidth(context) * 0.1,
                                child: Center(
                                  child: Text(
                                    "(${buyer.reviewsLink.averageRating.toString()})",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              )
                            ],
                          ),
                          ontap: () {
                            model.navigateToChatScreen(chatList[index].guid,
                                buyer.guid, chatList[index].itemGuid);
                          });
                    });
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: kPrimaryColor,
            ));
          }
        },
      ),
    );
  }
}
