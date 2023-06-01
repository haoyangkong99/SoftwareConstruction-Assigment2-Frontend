import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/route.locator.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/StripeAccountService.dart';
import 'package:utmletgo/services/_services.dart';

class PaymentHistoryViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _authService = locator<FirebaseAuthenticationService>();
  final _userService = locator<UserService>();
  final _dataPassingService = locator<DataPassingService>();
  final _orderService = locator<OrderService>();

  @override
  Map<String, StreamData> get streamsMap => {
        'user': StreamData<List<User>>(_userService.getAllUsersAsStream()),
        'order': StreamData<List<Order>>(
            _orderService.getOrderWithConditionAsStream(
                (order) => order.payment.method == 'Credit/Debit Card')),
      };
  String getCurrentUserGuid() {
    String guid = _dataPassingService.get('current_user_guid') as String;
    return guid;
  }
}
