import 'package:stacked/stacked.dart';
import 'package:utmletgo/app/route.locator.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';

class ViewOrderViewModel extends MultipleStreamViewModel {
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _orderService = locator<OrderService>();

  @override
  Map<String, StreamData> get streamsMap => {
        'user': StreamData<List<User>>(_userService.getAllUsersAsStream()),
        'order': StreamData<List<Order>>(getOrder()),
      };
  Stream<List<Order>> getOrder() {
    String itemGuid = _dataPassingService.get('item_guid') as String;
    return _orderService
        .getOrderWithConditionAsStream((order) => order.itemGuid == itemGuid);
  }

  Future<void> cancelOrder(String orderGuid) async {
    await _orderService.updateOrderStatus(orderGuid, OrderStatus.cancelled);
  }
}
