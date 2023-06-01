import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StripeAccount {
  String id, type, email;
  bool payouts_enabled, details_submitted;
  StripeAccount(
      {required this.email,
      required this.type,
      required this.id,
      required this.payouts_enabled,
      required this.details_submitted});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'type': type,
      'payouts_enabled': payouts_enabled,
      'details_submitted': details_submitted
    };
  }

  factory StripeAccount.fromMap(Map<String, dynamic>? map) {
    return StripeAccount(
      details_submitted: map!['details_submitted'] as bool,
      payouts_enabled: map['payouts_enabled'] as bool,
      id: map['id'] as String,
      email: map['email'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory StripeAccount.fromJson(String source) =>
      StripeAccount.fromMap(json.decode(source) as Map<String, dynamic>);
}
