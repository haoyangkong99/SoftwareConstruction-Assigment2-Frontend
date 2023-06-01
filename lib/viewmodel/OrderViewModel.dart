import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/OfferService.dart';
import 'package:utmletgo/services/OrderService.dart';
import 'package:utmletgo/services/StripeAccountService.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/shared/Exception.dart';
import 'package:utmletgo/view/Address/AddressScreen.dart';

class OrderViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _itemService = locator<ItemService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _orderService = locator<OrderService>();
  final _paymentService = locator<StripePaymentService>();
  final _accountService = locator<StripeAccountService>();
  Offer offer;
  OrderViewModel({required this.offer});
  @override
  Map<String, StreamData> get streamsMap => {
        'item': StreamData<Item>(getItem()),
        'user': StreamData<User>(getUser()),
        'seller': StreamData<List<User>>(getSeller())
      };
  Stream<Item> getItem() {
    String itemGuid = _dataPassingService.get('item_guid') as String;
    return _itemService.getItemByGuidAsStream(itemGuid);
  }

  Stream<User> getUser() {
    var userGuid = _dataPassingService.get('current_user_guid') as String;
    return _userService.getUserByGuidAsStream(userGuid);
  }

  Stream<List<User>> getSeller() {
    String itemGuid = _dataPassingService.get('item_guid') as String;
    return _userService.getUserWithConditionAsStream(
        (user) => user.itemLink.contains(itemGuid));
  }

  void navigateToAddressScreen() {
    _navigationService.popRepeated(1);
    _navigationService.navigateToView(AddressScreen());
  }

  void navigatePop() {
    _navigationService.popRepeated(1);
  }

  Future<void> createOrder(String offerGuid, String itemGuid, double amount,
      Address shippingAddress, Payment payment, String sellerGuid) async {
    await _orderService.addOrder(
        offerGuid, itemGuid, amount, shippingAddress, payment, sellerGuid);
  }

  Future<Map<String, dynamic>> payWithCard(
      String email, double amount, Address address, String destination) async {
    return await _paymentService.initPayment(
        email: email,
        amount: amount,
        address: address,
        destination: destination);
  }

  Future<bool> validateCanPlaceOrder() async {
    if (await _orderService.validateOrderExist(offer)) {
      throw GeneralException(
          title: "Order Existed For This Item",
          message:
              "You are not allowed to place order for this item as there exists order for this item");
    }
    return true;
  }

  Future<String> getSellerAccountId(String userGuid) async {
    StripeAccount account = await _accountService.getAccount(userGuid);
    return account.id;
  }
}
