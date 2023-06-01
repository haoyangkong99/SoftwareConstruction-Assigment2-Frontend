import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class StripeAccountLinks {
  int created, expires_at;
  String object, url;
  bool status;
  StripeAccountLinks(
      {required this.created,
      required this.expires_at,
      required this.url,
      required this.object,
      required this.status});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expires_at': expires_at,
      'url': url,
      'created': created,
      'object': object,
      'status': status
    };
  }

  factory StripeAccountLinks.fromMap(Map<String, dynamic>? map) {
    return StripeAccountLinks(
        created: map!['created'] as int,
        expires_at: map['expires_at'] as int,
        url: map['url'] as String,
        object: map['object'] as String,
        status: map['status'] as bool);
  }

  String toJson() => json.encode(toMap());

  factory StripeAccountLinks.fromJson(String source) =>
      StripeAccountLinks.fromMap(json.decode(source) as Map<String, dynamic>);
}
