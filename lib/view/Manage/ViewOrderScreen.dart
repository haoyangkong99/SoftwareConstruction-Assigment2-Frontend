import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/DateTimeConversion.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/Contact/_contact.dart';
import 'package:utmletgo/viewmodel/ViewOrderViewModel.dart';

class ViewOrderScreen extends StatefulWidget {
  const ViewOrderScreen({super.key});

  @override
  State<ViewOrderScreen> createState() => _ViewOrderScreenState();
}

class _ViewOrderScreenState extends State<ViewOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar(
        automaticallyImplyLeading: true,
        height: getMediaQueryHeight(context),
        title: const Text(
          "View Order",
          // style: TextStyle(color: Colors.white),
        ),
      ),
      body: ViewModelBuilder<ViewOrderViewModel>.reactive(
        viewModelBuilder: () => ViewOrderViewModel(),
        builder: (context, model, child) {
          if (model.dataReady('user') && model.dataReady('order')) {
            List<User> buyerList = model.dataMap!['user'];
            List<Order> orderList = model.dataMap!['order'];
            return orderList.isEmpty
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
                    itemCount: orderList.length,
                    itemBuilder: (context, index) {
                      User buyer = buyerList
                          .where((element) =>
                              orderList[index].buyerGuid == element.guid)
                          .first;
                      return ConversationCard(
                          img: buyer.profilePicture,
                          name: buyer.name,
                          subtitle: Text(
                            'RM ${orderList[index].amount.toStringAsFixed(2)}\nStatus: ${orderList[index].status.replaceAll(RegExp(r'_'), ' ').toUpperCase()}',
                            style: const TextStyle(
                                fontSize: 14.0, color: Colors.red),
                          ),
                          ontap: () async {
                            await showDialog(
                                context: context,
                                builder: (BuildContext ctx) => StatefulBuilder(
                                      builder: (BuildContext context,
                                              StateSetter setState) =>
                                          CustomDialogBox(
                                              title: 'Order Details',
                                              otherContent: ExpansionTile(
                                                initiallyExpanded: false,
                                                childrenPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 5),
                                                title: const Text(
                                                  "Payment Details",
                                                  style: TextStyle(
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                                children: [
                                                  ListView(
                                                    shrinkWrap: true,
                                                    children: [
                                                      Text(
                                                          "Method: ${orderList[index].payment.method}"),
                                                      Text(
                                                          "Payment Date Time: ${formateDateTime(convertToDateTime(orderList[index].payment.paymentDT), breakLine: false)}"),
                                                      Text(
                                                          "Total Amount: RM ${orderList[index].payment.amount.toStringAsFixed(2)}"),
                                                      const Text(
                                                        "Shipping Address:  ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "Address Line 1:  ${orderList[index].shippingAddress.addressLine1}"),
                                                      Text(
                                                          "Address Line 2:  ${orderList[index].shippingAddress.addressLine2}"),
                                                      Text(
                                                          "Postcode:  ${orderList[index].shippingAddress.postcode}"),
                                                      Text(
                                                          "City:  ${orderList[index].shippingAddress.city}"),
                                                      Text(
                                                          "State:  ${orderList[index].shippingAddress.state}"),
                                                      Text(
                                                          "Status:  ${orderList[index].status.replaceAll(RegExp(r'_'), ' ').toUpperCase()}"),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              isOtherContent: true,
                                              actions: [
                                                orderList[index].status ==
                                                        OrderStatus
                                                            .in_progress.name
                                                    ? Btn(
                                                        text: "Cancel Order",
                                                        textStyle:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16),
                                                        backgroundColor:
                                                            Colors.red,
                                                        borderColor: Colors.red,
                                                        width:
                                                            getMediaQueryWidth(
                                                                    context) *
                                                                0.3,
                                                        height:
                                                            getMediaQueryHeight(
                                                                    context) *
                                                                0.05,
                                                        onPressed: () async {
                                                          await model
                                                              .cancelOrder(
                                                                  orderList[
                                                                          index]
                                                                      .guid)
                                                              .then((value) =>
                                                                  Navigator.pop(
                                                                      context))
                                                              .then((value) =>
                                                                  showCompleteUpdateDialogBox(
                                                                      context))
                                                              .onError<
                                                                  Exception>((error,
                                                                      stackTrace) =>
                                                                  showExceptionErrorDialogBox(
                                                                      context,
                                                                      error,
                                                                      "Error Occured During Updating Statu"));
                                                        },
                                                        isRound: false)
                                                    : const Center(),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Close",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: kPrimaryColor),
                                                  ),
                                                ),
                                              ],
                                              isConfirm: true),
                                    ));
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
