import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/route.locator.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/view/Manage/MyPurchaseScreen.dart';

class ManagePurchaseViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _itemService = locator<ItemService>();
  final _dataPassingService = locator<DataPassingService>();
  final _orderService = locator<OrderService>();
  @override
  Map<String, StreamData> get streamsMap => {
        'item': StreamData<List<Item>>(_itemService.getAllItemsAsStream()),
        'order': StreamData<List<Order>>(getOrder())
      };
  Stream<List<Order>> getOrder() {
    String guid = _dataPassingService.get('current_user_guid') as String;
    return _orderService
        .getOrderWithConditionAsStream((order) => order.buyerGuid == guid);
  }

  Future<void> navigateToMyPurchaseScreen(String guid, int index) async {
    _dataPassingService.addToDataPassingList("item_guid", guid);
    OrderStatus status;
    switch (index) {
      case 0:
        status = OrderStatus.in_progress;
        break;
      case 1:
        status = OrderStatus.completed;
        break;

      default:
        status = OrderStatus.cancelled;
        break;
    }
    _navigationService.navigateToView(MyPurchaseScreen(
      status: status,
    ));
  }
}
