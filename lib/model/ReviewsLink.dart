// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ReviewsLink {
  double averageRating = 0;
  int reviewsCount = 0;
  List<String> reviewsGuid = List.empty();

  ReviewsLink();
  ReviewsLink.complete(this.averageRating, this.reviewsCount, this.reviewsGuid);

  Map<String, dynamic>? toMap() {
    return <String, dynamic>{
      'averageRating': averageRating,
      'reviewsCount': reviewsCount,
      'reviewsGuid': reviewsGuid,
    };
  }

  factory ReviewsLink.fromMap(Map<String, dynamic> map) {
    List<dynamic>? guidJson = map['reviewsGuid'];
    List<String>? guids = guidJson!.map((e) => e.toString()).toList();
    int averageRating = map['averageRating'] as int;
    int reviewsCount = map['reviewsCount'] as int;

    try {
      return ReviewsLink.complete(
          averageRating.toDouble(), reviewsCount, guids);
    } catch (e) {
      throw Exception(e);
    }
  }
  factory ReviewsLink.fromMapForItem(Map<String, dynamic> map) {
    List<dynamic>? guidJson = map['reviewsGuid'];
    List<String>? guids = guidJson!.map((e) => e.toString()).toList();

    try {
      return ReviewsLink.complete(
          map['averageRating'], map['reviewsCount'], guids);
    } catch (e) {
      throw Exception(e);
    }
  }

  String toJson() => json.encode(toMap());

  factory ReviewsLink.fromJson(String source) =>
      ReviewsLink.fromMap(json.decode(source) as Map<String, dynamic>);
}
