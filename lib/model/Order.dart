// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:utmletgo/model/_model.dart';

class Order {
  String guid = '',
      offerGuid = '',
      itemGuid = '',
      status = '',
      buyerGuid = '',
      sellerGuid = '';
  double amount = 0;
  Payment payment = Payment();
  Address shippingAddress = Address();
  Order();
  Order.complete(
      {required this.guid,
      required this.offerGuid,
      required this.itemGuid,
      required this.status,
      required this.amount,
      required this.payment,
      required this.shippingAddress,
      required this.buyerGuid,
      required this.sellerGuid});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'guid': guid,
      'offerGuid': offerGuid,
      'itemGuid': itemGuid,
      'status': status,
      'amount': amount,
      'payment': payment.toMap(),
      'shippingAddress': shippingAddress.toMap(),
      'buyerGuid': buyerGuid,
      'sellerGuid': sellerGuid
    };
  }

  factory Order.fromMap(Map<String, dynamic>? map) {
    return Order.complete(
        guid: map!['guid'] as String,
        offerGuid: map['offerGuid'] as String,
        itemGuid: map['itemGuid'] as String,
        status: map['status'] as String,
        amount: map['amount'] as double,
        payment: Payment.fromMap(map['payment'] as Map<String, dynamic>),
        shippingAddress:
            Address.fromMap(map['shippingAddress'] as Map<String, dynamic>),
        buyerGuid: map['buyerGuid'] as String,
        sellerGuid: map['sellerGuid'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) =>
      Order.fromMap(json.decode(source) as Map<String, dynamic>);
}
