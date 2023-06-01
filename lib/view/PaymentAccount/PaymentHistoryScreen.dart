import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/constants/constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/DateTimeConversion.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/viewmodel/PaymentHistoryViewModel.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<User> users = [];
  List<String> dates = ['24th June 2019', '29th June 2019', '2nd July 2019'];
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: basicAppBar(
          automaticallyImplyLeading: true,
          title: const Text(
            'Payment History',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat",
                fontSize: 18.0),
          ),
          height: getMediaQueryHeight(context),
        ),
        body: ViewModelBuilder<PaymentHistoryViewModel>.reactive(
          viewModelBuilder: () => PaymentHistoryViewModel(),
          builder: (context, model, child) {
            if (model.dataReady('user') && model.dataReady('order')) {
              List<User> userList = model.dataMap!['user'];
              List<Order> orderList = model.dataMap!['order'];
              String currentUserGuid = model.getCurrentUserGuid();
              orderList = orderList
                  .where((element) =>
                      element.buyerGuid == currentUserGuid ||
                      element.sellerGuid == currentUserGuid)
                  .toList();

              return orderList.isEmpty
                  ? Center(
                      child: Container(
                        height: getMediaQueryHeight(context) * 0.6,
                        width: getMediaQueryWidth(context),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                    'assets/images/No payment history.png'))),
                      ),
                    )
                  : SafeArea(
                      child: LayoutBuilder(
                          builder: (_, constraints) => Column(
                                children: [
                                  Expanded(
                                    child: GroupedListView<Order, String>(
                                      order: GroupedListOrder.DESC,
                                      controller: _scrollController,
                                      elements: orderList,
                                      groupBy: (Order order) =>
                                          DateFormat('d MMM y').format(
                                              convertToDateTime(
                                                  order.payment.paymentDT)),
                                      groupSeparatorBuilder:
                                          (String groupByValue) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(groupByValue,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold)),
                                        );
                                      },
                                      itemBuilder: (context, Order order) =>
                                          Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 5),
                                        child: Center(
                                          child: orderList.isEmpty
                                              ? CupertinoActivityIndicator()
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        spreadRadius: 2,
                                                        blurRadius: 5,
                                                        offset: Offset(0,
                                                            3), // changes position of shadow
                                                      ),
                                                    ],
                                                  ),
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 8.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Column(
                                                        children: <Widget>[
                                                          Row(
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            16.0),
                                                                child:
                                                                    CircleAvatar(
                                                                  maxRadius: 24,
                                                                  backgroundImage: NetworkImage(order
                                                                              .buyerGuid ==
                                                                          currentUserGuid
                                                                      ? userList
                                                                          .where((element) =>
                                                                              element.guid ==
                                                                              order
                                                                                  .sellerGuid)
                                                                          .first
                                                                          .profilePicture
                                                                      : userList
                                                                          .where((element) =>
                                                                              element.guid ==
                                                                              order.buyerGuid)
                                                                          .first
                                                                          .profilePicture),
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            16.0),
                                                                    child: Text(
                                                                        order.buyerGuid ==
                                                                                currentUserGuid
                                                                            ? userList.where((element) => element.guid == order.sellerGuid).first.name
                                                                            : userList.where((element) => element.guid == order.buyerGuid).first.name,
                                                                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                                                                  ),
                                                                  Text(
                                                                    order.buyerGuid ==
                                                                            currentUserGuid
                                                                        ? "Paid"
                                                                        : "Received",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0),
                                                                  )
                                                                ],
                                                              ),
                                                              Spacer(),
                                                              Column(
                                                                children: <
                                                                    Widget>[
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        '\RM ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 10.0),
                                                                      ),
                                                                      Text(
                                                                        order
                                                                            .amount
                                                                            .toStringAsFixed(2),
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            8.0),
                                                                    child: Text(
                                                                        formateTime(convertToDateTime(order
                                                                            .payment
                                                                            .paymentDT)),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey)),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 64.0),
                                                            child: Divider(),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                    );
            } else {
              return Center(
                  child: CircularProgressIndicator(
                color: kPrimaryColor,
              ));
            }
          },
        ));
  }
}
