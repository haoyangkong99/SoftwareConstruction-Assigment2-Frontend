import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/Exception.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/viewmodel/OrderViewModel.dart';

class OrderScreen extends StatefulWidget {
  Offer offer;
  OrderScreen({super.key, required this.offer});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  SwiperController addressController = SwiperController();
  SwiperController paymentController = SwiperController();
  int? selectedPaymentMethod;
  List<String> paymentMethods = [
    'Cash On Delivery (COD)',
    'Credit/Debit Card',
    'Self-arrange'
  ];
  int? selectedCardIndex;
  int? selectedAddress;
  int currentIndex = 0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: basicAppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          'Order',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Montserrat",
              fontSize: 18.0),
        ),
        height: getMediaQueryHeight(context),
      ),
      body: ViewModelBuilder<OrderViewModel>.reactive(
        viewModelBuilder: () => OrderViewModel(offer: widget.offer),
        builder: (context, model, child) {
          if (model.dataReady('user') &&
              model.dataReady('item') &&
              model.dataReady('seller')) {
            User user = model.dataMap!['user'];
            Item item = model.dataMap!['item'];
            List<User> list = model.dataMap!['seller'];
            User seller = list.first;
            List<String> methodsTobeRemoved = paymentMethods
                .where((element) => !item.paymentMethods!.contains(element))
                .toList();
            methodsTobeRemoved.forEach((element) {
              paymentMethods.remove(element);
            });

            return isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ))
                : SingleChildScrollView(
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        child: ItemCard(
                            img: item.coverImage,
                            title: item.title,
                            price: widget.offer.price,
                            quantity: item.quantity),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 7),
                                  blurRadius: 6)
                            ],
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            InkWell(
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder:
                                        (BuildContext ctx) => StatefulBuilder(
                                              builder: (BuildContext context,
                                                      StateSetter setState) =>
                                                  CustomDialogBox(
                                                      title: 'Select Payment',
                                                      otherContent: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: List.generate(
                                                              paymentMethods.length,
                                                              (index) => RadioListTile(
                                                                  title: Text(paymentMethods[index]),
                                                                  value: index + 1,
                                                                  groupValue: selectedPaymentMethod,
                                                                  onChanged: (int? value) {
                                                                    setState(
                                                                        () {
                                                                      selectedPaymentMethod =
                                                                          value!;
                                                                    });
                                                                  }))),
                                                      isOtherContent: true,
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Ok",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    kPrimaryColor),
                                                          ),
                                                        ),
                                                      ],
                                                      isConfirm: true),
                                            ));
                                setState(() {});
                              },
                              child: ListTile(
                                title: const Text('Payment Method'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    selectedPaymentMethod == null
                                        ? const Center()
                                        : Text(paymentMethods[
                                            selectedPaymentMethod! - 1]),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFE2E2E2),
                            ),
                            InkWell(
                              onTap: () async {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext ctx) =>
                                        StatefulBuilder(
                                          builder: (BuildContext context,
                                                  StateSetter setState) =>
                                              CustomDialogBox(
                                                  title:
                                                      'Select Shipping Address',
                                                  otherContent: user
                                                          .addresses.isEmpty
                                                      ? Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              height: getMediaQueryHeight(
                                                                      context) *
                                                                  0.3,
                                                              width: getMediaQueryWidth(
                                                                      context) *
                                                                  0.8,
                                                              decoration: const BoxDecoration(
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      image: AssetImage(
                                                                          'assets/images/Empty address.png'))),
                                                            ),
                                                            Btn(
                                                                text:
                                                                    "Add Address",
                                                                textStyle: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                                backgroundColor:
                                                                    Colors.teal,
                                                                borderColor:
                                                                    Colors.teal,
                                                                width: getMediaQueryWidth(
                                                                        context) *
                                                                    0.5,
                                                                height: getMediaQueryHeight(
                                                                        context) *
                                                                    0.02,
                                                                onPressed:
                                                                    () async {
                                                                  model
                                                                      .navigateToAddressScreen();
                                                                },
                                                                isRound: false),
                                                          ],
                                                        )
                                                      : Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: List.generate(
                                                              user.addresses.length,
                                                              (index) => RadioListTile(
                                                                  title: Wrap(children: [
                                                                    Text(
                                                                        'Type: ${user.addresses[index].type}\n${user.addresses[index].addressLine1},\n${user.addresses[index].addressLine2},\n${user.addresses[index].postcode} ${user.addresses[index].city}, ${user.addresses[index].state} '),
                                                                  ]),
                                                                  value: index,
                                                                  groupValue: selectedAddress,
                                                                  onChanged: (int? value) {
                                                                    selectedAddress =
                                                                        value;
                                                                    setState(
                                                                        () {});
                                                                  }))),
                                                  isOtherContent: true,
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text(
                                                        user.addresses.isEmpty
                                                            ? "Close"
                                                            : "Ok",
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                kPrimaryColor),
                                                      ),
                                                    ),
                                                  ],
                                                  isConfirm: true),
                                        ));
                                setState(() {});
                              },
                              child: ListTile(
                                title: const Text('Shipping Address'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    selectedAddress == null
                                        ? const Center()
                                        : const Text('Selected'),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                              color: Color(0xFFE2E2E2),
                            ),
                            ListTile(
                              title: const Text(
                                'Total',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              trailing: Text(
                                'RM ${widget.offer.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: getMediaQueryHeight(context) * 0.1,
                      ),
                      Center(
                        child: Btn(
                            text: "Place Order",
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            backgroundColor: kPrimaryColor,
                            borderColor: kPrimaryColor,
                            width: getMediaQueryWidth(context) * 0.75,
                            height: getMediaQueryHeight(context) * 0.07,
                            onPressed: () async {
                              if (selectedPaymentMethod == null ||
                                  selectedAddress == null) {
                                showIncompleteFieldsDialogBox(context);
                              } else {
                                if (paymentMethods[
                                        selectedPaymentMethod! - 1] ==
                                    'Credit/Debit Card') {
                                  String destination = await model
                                      .getSellerAccountId(seller.guid);
                                  await model
                                      .validateCanPlaceOrder()
                                      .then((value) => model
                                          .payWithCard(
                                              user.email,
                                              widget.offer.price,
                                              user.addresses[selectedAddress!],
                                              destination)
                                          .then((response) => model.createOrder(
                                              widget.offer.guid,
                                              item.guid,
                                              widget.offer.price,
                                              user.addresses[selectedAddress!],
                                              Payment.complete(
                                                  method: paymentMethods[
                                                      selectedPaymentMethod! -
                                                          1],
                                                  status: PaymentStatus
                                                      .successful.name,
                                                  amount: widget.offer.price,
                                                  paymentDT:
                                                      DateTime.now().toString(),
                                                  paymentInfo: response),
                                              seller.guid)))
                                      .then((value) async => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const CustomDialogBox(
                                              title:
                                                  'Your Order has been placed',
                                              content:
                                                  "Your order has been placed and is on it's way to being processed",
                                            );
                                          }))
                                      .then((value) => model.navigatePop())
                                      .onError<GeneralException>(
                                          (error, stackTrace) {
                                    showGeneralExceptionErrorDialogBox(
                                        context, error);
                                  });
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await model
                                      .validateCanPlaceOrder()
                                      .then((result) => model.createOrder(
                                          widget.offer.guid,
                                          item.guid,
                                          widget.offer.price,
                                          user.addresses[selectedAddress!],
                                          Payment.complete(
                                              method: paymentMethods[
                                                  selectedPaymentMethod! - 1],
                                              status:
                                                  PaymentStatus.successful.name,
                                              amount: widget.offer.price,
                                              paymentDT:
                                                  DateTime.now().toString(),
                                              paymentInfo: {}),
                                          seller.guid))
                                      .then((value) => setState(() {
                                            isLoading = false;
                                          }))
                                      .then((value) async => showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const CustomDialogBox(
                                              title:
                                                  'Your Order has been placed',
                                              content:
                                                  "Your order has been placed and is on it's way to being processed",
                                            );
                                          }))
                                      .then((value) => model.navigatePop())
                                      .onError<GeneralException>((error,
                                              stackTrace) =>
                                          showGeneralExceptionErrorDialogBox(
                                              context, error));
                                }
                              }
                            },
                            isRound: false),
                      ),
                    ]),
                  );
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

  Widget checkoutRow(String label,
      {String? trailingText, Widget? trailingWidget}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 15,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF7C7C7C),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          trailingText == null
              ? (trailingWidget ?? Container())
              : Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }
}
