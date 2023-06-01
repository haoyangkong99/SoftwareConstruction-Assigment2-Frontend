import 'package:card_swiper/card_swiper.dart';
import 'package:enhanced_read_more/enhanced_read_more.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/DateTimeConversion.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Marketplace/UserProfileScreen.dart';
import 'package:utmletgo/view/Review/ReviewScreen.dart';
import 'package:utmletgo/viewmodel/_viewmodel.dart';

class MyPurchaseScreen extends StatefulWidget {
  OrderStatus status;
  MyPurchaseScreen({super.key, required this.status});

  @override
  State<MyPurchaseScreen> createState() => _MyPurchaseScreenState();
}

class _MyPurchaseScreenState extends State<MyPurchaseScreen> {
  List<String> images = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double height = getMediaQueryHeight(context);
    double width = getMediaQueryWidth(context);
    return ViewModelBuilder<ItemViewModel>.reactive(
        viewModelBuilder: () => ItemViewModel(),
        builder: (context, model, child) {
          if (model.dataReady('user') &&
              model.dataReady('item') &&
              model.dataReady('order')) {
            Item item = model.dataMap!['item'] as Item;
            List<User> userList = model.dataMap!['user'] as List<User>;
            User seller = userList.first;
            images.clear();
            images.add(item.coverImage);
            images.addAll(item.images!.map((e) => e));
            List<Order> orderList = model.dataMap!['order'] as List<Order>;
            orderList.sort((a, b) => convertToDateTime(b.payment.paymentDT)
                .compareTo(convertToDateTime(a.payment.paymentDT)));
            Order order = orderList
                    .where((element) => element.status == widget.status.name)
                    .isEmpty
                ? orderList.first
                : orderList
                    .where((element) => element.status == widget.status.name)
                    .first;

            Widget showButtons() {
              List<Widget> widgetList = [];
              widgetList.clear();
              widgetList.add(Btn(
                  text: "Contact",
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                  backgroundColor: kPrimaryColor,
                  borderColor: kPrimaryColor,
                  width: width * 0.3,
                  height: height * 0.05,
                  onPressed: () {
                    model.navigateToChatScreen(order.itemGuid, seller.guid);
                  },
                  isRound: false));
              if (order.status == OrderStatus.in_progress.name) {
                widgetList.add(Btn(
                    text: "Cancel",
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    backgroundColor: Colors.red,
                    borderColor: Colors.red,
                    width: width * 0.3,
                    height: height * 0.05,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await model
                          .updateOrderStatus(order.guid, OrderStatus.cancelled)
                          .whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                      }).onError<Exception>((error, stackTrace) =>
                              showExceptionErrorDialogBox(context, error,
                                  "Error Occured During Updating Status"));
                    },
                    isRound: false));
              }
              if (order.status == OrderStatus.completed.name) {
                widgetList.add(Btn(
                    text: "Rate & Review",
                    textStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    backgroundColor: Colors.lightBlue,
                    borderColor: Colors.lightBlue,
                    width: width * 0.3,
                    height: height * 0.05,
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ReviewScreen(
                                sellerGuid: seller.guid,
                              )));
                    },
                    isRound: false));
              }
              if (order.status == OrderStatus.in_progress.name) {
                widgetList.add(Btn(
                    text: "Mark As Completed",
                    textStyle:
                        const TextStyle(color: Colors.black, fontSize: 16),
                    backgroundColor: Colors.white,
                    borderColor: Colors.grey,
                    width: width * 0.3,
                    height: height * 0.05,
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await model
                          .updateOrderStatus(order.guid, OrderStatus.completed)
                          .whenComplete(() {
                        setState(() {
                          isLoading = false;
                        });
                      }).onError<Exception>((error, stackTrace) =>
                              showExceptionErrorDialogBox(context, error,
                                  "Error Occured During Updating Status"));
                    },
                    isRound: false));
              }
              return Wrap(
                runAlignment: WrapAlignment.center,

                alignment: WrapAlignment.spaceEvenly,
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widgetList,
              );
            }

            ImageProvider showProfilePicture() {
              if (seller.profilePicture.isNotEmpty) {
                return NetworkImage(seller.profilePicture);
              } else {
                return AssetImage(seller.gender == Gender.Male.name
                    ? "assets/images/man profile icon.png"
                    : "assets/images/lady profile icon.png");
              }
            }

            return Scaffold(
              appBar: basicAppBar(
                height: getMediaQueryHeight(context),
                automaticallyImplyLeading: true,
                title: const Text(
                  "My Purchase",
                ),
              ),
              body: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: kPrimaryColor,
                    ))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                        child: Column(
                          // shrinkWrap: true,
                          children: <Widget>[
                            const SizedBox(height: 10.0),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: SizedBox(
                                height: height * 0.3,
                                child: Swiper(
                                  control: const SwiperControl(),
                                  loop: false,
                                  indicatorLayout: PageIndicatorLayout.DROP,
                                  itemCount: images.length,
                                  itemBuilder: (context, idx) => Container(
                                    height: MediaQuery.of(context).size.height /
                                        3.2,
                                    width: MediaQuery.of(context).size.width,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        images[idx],
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "RM ${item.price.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                      fontSize: 14.0, color: Colors.red),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Quantity: ${item.quantity.toString()}",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            const SubTitleHeader(
                                text: "Category - SubCategory"),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "${item.category} - ${item.subcategory}",
                                  style: const TextStyle(
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ),
                            const SubTitleHeader(text: "Description"),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: ReadMoreText(
                                  item.description,
                                  style: const TextStyle(wordSpacing: 2),
                                  trimLines: 4,
                                  collapsed: true,
                                  colorClickableText: Colors.blue[700],
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'Show more',
                                  trimExpandedText: 'Show less',
                                  moreStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700]),
                                  lessStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[300]),
                                ),
                              ),
                            ),
                            const SubTitleHeader(
                              text: "Seller",
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserProfileScreen(
                                            userGuid: seller.guid)));
                              },
                              child: UserListTile(
                                image: showProfilePicture(),
                                title: seller.name,
                                rating: seller.reviewsLink.averageRating,
                              ),
                            ),
                            const SubTitleHeader(text: "Order Status"),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                // alignment: WrapAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Chip(
                                    backgroundColor: kPrimaryColor,
                                    label: Text(
                                      order.status
                                          .replaceAll(RegExp(r'_'), ' ')
                                          .toUpperCase(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ExpansionTile(
                              initiallyExpanded: false,
                              childrenPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              title: const Text(
                                "Payment Details",
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              children: [
                                ListView(
                                  shrinkWrap: true,
                                  children: [
                                    Text("Method: ${order.payment.method}"),
                                    Text(
                                        "Payment Date Time: ${formateDateTime(convertToDateTime(order.payment.paymentDT), breakLine: false)}"),
                                    Text(
                                        "Total Amount: RM ${order.payment.amount.toStringAsFixed(2)}"),
                                    const Text(
                                      "Shipping Address:  ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "Address Line 1:  ${order.shippingAddress.addressLine1}"),
                                    Text(
                                        "Address Line 2:  ${order.shippingAddress.addressLine2}"),
                                    Text(
                                        "Postcode:  ${order.shippingAddress.postcode}"),
                                    Text(
                                        "City:  ${order.shippingAddress.city}"),
                                    Text(
                                        "State:  ${order.shippingAddress.state}"),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          top: BorderSide(color: Colors.grey, width: 1))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: showButtons(),
                  )),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            );
          }
        });
  }
}
