import 'dart:convert';
import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:utmletgo/model/StripeAccount.dart';
import 'package:utmletgo/model/StripeAccountLinks.dart';

import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/shared/Exception.dart';

import '../model/Address.dart' as address;

class StripePaymentService {
  FirebaseDbService dbService = FirebaseDbService();
  Stripe stripe = Stripe.instance;
  UserService userService = UserService();
  Future<Map<String, dynamic>> initPayment(
      {required String email,
      required double amount,
      required address.Address address,
      required String destination}) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(Uri.parse(''), body: {
        'email': email,
        'amount': (amount * 100).toString(),
        'destination': destination
      });

      final jsonResponse = jsonDecode(response.body);
      log(jsonResponse.toString());

      // 2. Initialize the payment sheet

      await stripe.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              billingDetails: BillingDetails(
                  address: Address(
                      city: address.city,
                      country: 'Malaysia',
                      line1: address.addressLine1,
                      line2: address.addressLine2,
                      postalCode: address.postcode,
                      state: address.state)),
              paymentIntentClientSecret: jsonResponse['paymentIntent'],
              merchantDisplayName: 'UTM Let Go',
              customerId: jsonResponse['customer'],
              customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
              allowsDelayedPaymentMethods: true));

      await stripe.presentPaymentSheet();

      Map<String, dynamic> convertedMap = jsonResponse.cast<String, dynamic>();
      return convertedMap;
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {
        throw GeneralException(
            title: 'Error occured during payment', message: error.toString());
      }
    }
  }

  Future<bool> createStripeStandardAccount(
      String email, String documentID) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(Uri.parse(''),
          body: {'email': email, "documentID": documentID});
      dynamic res = jsonDecode(response.body);
      if (res['success'] as bool) {
        return true;
      } else {
        throw GeneralException(
            title: 'Error occured when creating account',
            message: res['error']);
      }
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {
        throw GeneralException(
            title: 'Error occured when creating account',
            message: error.toString());
      }
    }
  }

  Future<StripeAccount> retrieveStripeAccount(
      String accountId, String documentID) async {
    try {
      final response = await http.post(Uri.parse(''),
          body: {'accountID': accountId, 'documentID': documentID});
      dynamic res = jsonDecode(response.body);
      if (res['success'] as bool) {
        return StripeAccount.fromMap(res['account']);
      } else {
        throw GeneralException(title: 'Error occured ', message: res['error']);
      }
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {
        throw GeneralException(
            title: 'Error occured', message: error.toString());
      }
    }
  }

  Stream<StripeAccount> retrieveStripeAccountAsStream(
      String accountId, String documentID) async* {
    try {
      final response = await http.post(Uri.parse(''),
          body: {'accountID': accountId, 'documentID': documentID});
      dynamic res = jsonDecode(response.body);
      if (response.statusCode == 200 && res['success'] as bool) {
        yield StripeAccount.fromMap(res['account']);
      } else {
        throw GeneralException(title: 'Error occured ', message: res['error']);
      }
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {
        throw GeneralException(
            title: 'Error occured', message: error.toString());
      }
    }
  }

  Future<String> generateOnboardingLink(
      String accountId, String documentID) async {
    try {
      final response = await http.post(Uri.parse(''),
          body: {'accountID': accountId, 'documentID': documentID});
      dynamic res = jsonDecode(response.body);
      if (res['success'] as bool) {
        return res['link'];
      } else {

        throw GeneralException(
            title: 'Error occured when generating link', message: res['error']);
      }
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {

        throw GeneralException(
            title: 'Error occured', message: error.toString());
      }
    }
  }

  Future<String> generateUpdateAccountLink(
      String accountId, String documentID) async {
    try {
      final response = await http.post(Uri.parse(''),
          body: {'accountID': accountId, 'documentID': documentID});
      dynamic res = jsonDecode(response.body);
      if (res['success'] as bool) {
        return res['link'];
      } else {

        throw GeneralException(title: 'Error occured', message: res['error']);
      }
    } catch (error) {
      if (error is StripeException) {
        throw GeneralException(
            title: error.error.code.name, message: error.error.message);
      } else {

        throw GeneralException(
            title: 'Error occured', message: error.toString());
      }
    }
  }
}
