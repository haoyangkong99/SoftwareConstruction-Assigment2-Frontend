import 'package:stacked/stacked.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';

class ReviewsViewModel extends MultipleStreamViewModel {
  final _itemService = locator<ItemService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _reviewsService = locator<ReviewsService>();
  final _orderService = locator<OrderService>();

  String userGuid = '';
  ReviewsViewModel({required this.userGuid});
  @override
  Map<String, StreamData> get streamsMap => {
        'reviews':
            StreamData<List<Reviews>>(_reviewsService.getAllReviewsAsStream()),
        'seller':
            StreamData<User>(_userService.getUserByGuidAsStream(userGuid)),
        'orderList': StreamData<List<Order>>(getCompletedOrderList()),
        'userList': StreamData<List<User>>(_userService.getAllUsersAsStream()),
        'itemList': StreamData<List<Item>>(_itemService.getAllItemsAsStream()),
      };
  Stream<List<Order>> getCompletedOrderList() {
    String currentUserGuid =
        _dataPassingService.get('current_user_guid') as String;
    return _orderService.getOrderWithConditionAsStream((order) =>
        order.buyerGuid == currentUserGuid &&
        order.status == OrderStatus.completed.name);
  }

  Stream<List<User>> getReviewers() {
    List<Reviews> reviews = streamsMap['reviews']!.data;
    List<String> involvedReviewerGuidList =
        reviews.map((e) => e.itemGuid).toList();
    return _userService.getUserWithConditionAsStream(
        (p0) => involvedReviewerGuidList.contains(p0.guid));
  }

  Future<void> createReviews(
      String itemGuid, double rating, String feedback) async {
    String reviewerGuid =
        await _userService.getCurrentUser().then((value) => value.guid);
    await _reviewsService.addReview(rating, feedback, itemGuid, reviewerGuid);
  }
}
