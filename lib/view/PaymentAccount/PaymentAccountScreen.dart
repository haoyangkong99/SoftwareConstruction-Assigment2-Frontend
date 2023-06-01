import 'package:card_swiper/card_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/StripeAccountLinks.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/shared/Exception.dart';
import 'package:utmletgo/shared/StateDropDownButton.dart';
import 'package:utmletgo/shared/_shared.dart';
import 'package:utmletgo/view/PaymentAccount/PaymentHistoryScreen.dart';
import 'package:utmletgo/viewmodel/PaymentAccountViewModel.dart';
import 'package:utmletgo/viewmodel/_viewmodel.dart';

class PaymentAccountScreen extends StatefulWidget {
  const PaymentAccountScreen({super.key});

  @override
  State<PaymentAccountScreen> createState() => _PaymentAccountScreenState();
}

class _PaymentAccountScreenState extends State<PaymentAccountScreen> {
  final TextEditingController fullName = TextEditingController();
  final TextEditingController accountNo = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final Validation _validator = Validation();
  final SwiperController _swiper = SwiperController();
  bool initial = true, isLoading = false;
  int currentIndex = 0;

  List<String> bankList = MalaysiaBank.values
      .map((e) => e.name.replaceAll(RegExp(r'_'), ' '))
      .toList();
  String selectedBank = '';
  @override
  void initState() {
    super.initState();
    selectedBank = bankList[0];
  }

  @override
  Widget build(BuildContext context) {
    double height = getMediaQueryHeight(context);
    return Scaffold(
      appBar: basicAppBar(
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentHistoryScreen()));
              },
              icon: Icon(
                Icons.history,
                color: Colors.white,
              ))
        ],
        title: const Text(
          'Payment Account',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Montserrat",
              fontSize: 18.0),
        ),
        height: getMediaQueryHeight(context),
      ),
      body: ViewModelBuilder<PaymentAccountViewModel>.reactive(
        viewModelBuilder: () => PaymentAccountViewModel(),
        builder: (context, model, child) {
          if (!isLoading && model.dataReady('user')) {
            User user = model.dataMap!['user'] as User;
            StripeAccount? account =
                model.dataMap!['account'] as StripeAccount?;
            StripeAccountLinks? link =
                model.dataMap!['link'] as StripeAccountLinks?;
            return Form(
              key: _formkey,
              child: LayoutBuilder(
                builder: (_, viewportConstraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            account == null ? Colors.white : Colors.grey[100],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: getMediaQueryWidth(context) * 0.05,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: height * 0.06,
                          ),
                          account == null
                              ? Container(
                                  height: getMediaQueryHeight(context) * 0.4,
                                  width: getMediaQueryWidth(context),
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          fit: BoxFit.contain,
                                          image: AssetImage(
                                              'assets/images/No account.png'))),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(0, 3),
                                            blurRadius: 5)
                                      ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Account ID: ${account.id}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Email: ${account.email}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Payout Enabled: ${account.payouts_enabled.toString().toUpperCase()}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Details Submitted: ${account.details_submitted.toString().toUpperCase()}",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: account != null &&
                                                account.details_submitted &&
                                                account.payouts_enabled
                                            ? const Text(
                                                'You have completed setting up of your account profile',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                ))
                                            : Row(
                                                children: [
                                                  Text(
                                                    account.details_submitted
                                                        ? "Update Link: "
                                                        : "Onboarding Link: ",
                                                    style: const TextStyle(
                                                      fontSize: 14.0,
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    child: !link!.status ||
                                                            DateTime.fromMillisecondsSinceEpoch(
                                                                    link.expires_at *
                                                                        1000)
                                                                .isBefore(
                                                                    DateTime
                                                                        .now())
                                                        ? const Text(
                                                            'The current link is deactivated.\nPlease generate a new link',
                                                            maxLines: 3,
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ))
                                                        : GestureDetector(
                                                            onTap: () async {
                                                              await model
                                                                  .launchLink(
                                                                      link.url)
                                                                  .then(
                                                                      (value) async {
                                                                link.status =
                                                                    false;
                                                                await model
                                                                    .updateAccountLinkStatus(
                                                                        link);
                                                              });
                                                            },
                                                            child: const Text(
                                                              'Click me to open the link',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            ),
                                                          ),
                                                  )
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: getMediaQueryHeight(context) * 0.05,
                          ),
                          account != null &&
                                  account.details_submitted &&
                                  account.payouts_enabled
                              ? const Center()
                              : Center(
                                  child: Btn(
                                      text: account == null
                                          ? "Set Up"
                                          : account.details_submitted
                                              ? "Generate Update Account Link"
                                              : "Generate Onboarding Link",
                                      textStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      backgroundColor: kPrimaryColor,
                                      borderColor: kPrimaryColor,
                                      width: getMediaQueryWidth(context) * 0.75,
                                      height:
                                          getMediaQueryHeight(context) * 0.07,
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (account == null) {
                                          await model
                                              .setUpAccount(user.email)
                                              .onError<GeneralException>((error,
                                                      stackTrace) =>
                                                  showGeneralExceptionErrorDialogBox(
                                                      context, error));
                                        } else {
                                          await model
                                              .retrieveAccount(account.id)
                                              .onError<GeneralException>((error,
                                                      stackTrace) =>
                                                  showGeneralExceptionErrorDialogBox(
                                                      context, error));
                                          if (account.details_submitted) {
                                            if (!account.payouts_enabled) {
                                              await model
                                                  .generateUpdateAccountLink(
                                                      account.id)
                                                  .then((value) =>
                                                      showCompleteGenerateLinkDialogBox(
                                                          context))
                                                  .onError<
                                                      GeneralException>((error,
                                                          stackTrace) =>
                                                      showGeneralExceptionErrorDialogBox(
                                                          context, error));
                                            }
                                          } else {
                                            await model
                                                .generateOnboardingLink(
                                                    account.id)
                                                .then((value) =>
                                                    showCompleteGenerateLinkDialogBox(
                                                        context))
                                                .onError<
                                                    GeneralException>((error,
                                                        stackTrace) =>
                                                    showGeneralExceptionErrorDialogBox(
                                                        context, error));
                                          }
                                        }
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      isRound: false),
                                ),
                          account != null &&
                                  account.details_submitted &&
                                  account.payouts_enabled
                              ? Center(
                                  child: Btn(
                                      text: 'Connect to your Stripe Account',
                                      textStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                      backgroundColor: Colors.purple,
                                      borderColor: Colors.purple,
                                      width: getMediaQueryWidth(context) * 0.6,
                                      height:
                                          getMediaQueryHeight(context) * 0.07,
                                      onPressed: () async {
                                        await model.launchLink(
                                            'https://stripe.com/en-my');
                                      },
                                      isRound: false),
                                )
                              : const Center()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
}
