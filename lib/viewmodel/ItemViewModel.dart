import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:utmletgo/app/_route.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/ChatService.dart';
import 'package:utmletgo/services/DataPassingService.dart';
import 'package:utmletgo/services/FirebaseStorageService.dart';
import 'package:utmletgo/services/ItemService.dart';
import 'package:utmletgo/services/OrderService.dart';
import 'package:utmletgo/services/StripeAccountService.dart';
import 'package:utmletgo/services/UserService.dart';
import 'package:utmletgo/shared/Validation.dart';
import 'package:utmletgo/view/Contact/ChatScreen.dart';
import 'package:utmletgo/view/Marketplace/FilterScreen.dart';
import 'package:utmletgo/view/Marketplace/UserProfileScreen.dart';

class ItemViewModel extends MultipleStreamViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _itemService = locator<ItemService>();
  final _storageService = locator<FirebaseStorageService>();
  final _dataPassingService = locator<DataPassingService>();
  final _userService = locator<UserService>();
  final _chatService = locator<ChatService>();
  final _orderService = locator<OrderService>();
  final _accountService = locator<StripeAccountService>();
  @override
  Map<String, StreamData> get streamsMap => {
        'item': StreamData<Item>(getItem()),
        'user': StreamData<List<User>>(getUser()),
        'order': StreamData<List<Order>>(getOrder()),
        'account':
            StreamData<StripeAccount>(_accountService.getAccountAsStream())
      };
  void navigateToFilterScreen() {
    _navigationService.navigateToView(const FilterScreen());
  }

  Stream<List<Order>> getOrder() {
    String? itemGuid = _dataPassingService.get('item_guid') as String?;
    itemGuid ??= '';
    return _orderService
        .getOrderWithConditionAsStream((order) => order.itemGuid == itemGuid);
  }

  Stream<Item> getItem() {
    var itemGuid = _dataPassingService.get('item_guid') as String?;
    itemGuid ??= '';
    return _itemService.getItemByGuidAsStream(itemGuid);
  }

  Stream<List<User>> getUser() {
    var itemGuid = _dataPassingService.get('item_guid') as String?;
    itemGuid ??= '';
    return _userService.getUserWithConditionAsStream(
        (user) => user.itemLink.any((element) => element == itemGuid));
  }

  Future<void> createItem(
      XFile? coverImage,
      String? category,
      String? subcategory,
      String? condition,
      String title,
      String description,
      String location,
      List<XFile?> images,
      List<String>? paymentMethods,
      double price,
      int quantity) async {
    String coverImageUrl = await _storageService
        .uploadImageToStorage(_storageService.convertXFileToFile(coverImage));

    List<String> otherImageUrls =
        await _storageService.uploadMultipleImagesToStorage(
            _storageService.convertXFilesToFile(images));
    String postedDT = DateTime.now().toString();
    await _itemService.addItem(
        coverImageUrl,
        category!,
        subcategory!,
        condition!,
        title,
        description,
        location,
        ItemStatus.to_start.name,
        postedDT,
        VisibilityType.allow.name,
        otherImageUrls,
        paymentMethods!,
        price,
        quantity);
    await _dialogService
        .showDialog(
            title: 'Successfully Posted',
            description: 'The new item has been posted successfully.',
            buttonTitleColor: kPrimaryColor)
        .then((value) =>
            _navigationService.pushNamedAndRemoveUntil(Routes.mainScreen));
  }

  Future<void> updateItem(
      Item item,
      List<String> allImgUrls,
      String? category,
      String? subcategory,
      String? condition,
      String title,
      String description,
      String location,
      List<String>? paymentMethods,
      double price,
      int quantity) async {
    String coverImageUrl = '';
    if (!Validation().isURL(allImgUrls[0])) {
      coverImageUrl = await _storageService.uploadImageToStorage(
          _storageService.convertXFileToFile(XFile(allImgUrls[0])));
    } else {
      coverImageUrl = item.coverImage;
    }
    List<String> imagesTobeRemoved = [];
    if (allImgUrls[0] != item.coverImage) {
      imagesTobeRemoved.add(item.coverImage);
    }
    List<String> tempList =
        item.images!.where((element) => !allImgUrls.contains(element)).toList();
    imagesTobeRemoved.addAll(tempList);
    List<String> otherImageUrls = [];
    for (int i = 1; i < allImgUrls.length; i++) {
      if (Validation().isURL(allImgUrls[i])) {
        otherImageUrls.add(allImgUrls[i]);
      } else {
        String temp = await _storageService.uploadImageToStorage(
            _storageService.convertXFileToFile(XFile(allImgUrls[i])));
        otherImageUrls.add(temp);
      }
    }
    imagesTobeRemoved.forEach((element) async {
      await _storageService.deleteFromStorage(element);
    });

    await _itemService.updateItem(
        item.guid,
        coverImageUrl,
        category!,
        subcategory!,
        condition!,
        title,
        description,
        location,
        otherImageUrls,
        paymentMethods!,
        price,
        quantity);
  }

  bool validateFields(GlobalKey<FormState>? key) {
    return key!.currentState!.validate();
  }

  Future<void> navigateToChatScreen(
      String itemGuid, String receiverGuid) async {
    Chat result =
        await _chatService.getChatAndCreateIfNotExist(itemGuid, receiverGuid);
    _dataPassingService.addToDataPassingList("receiver_guid", receiverGuid);
    _dataPassingService.addToDataPassingList("chat_guid", result.guid);
    _navigationService.navigateToView(ChatScreen());
  }

  Future<void> makeOffer(
      String itemGuid, String receiverGuid, String message) async {
    Chat result =
        await _chatService.getChatAndCreateIfNotExist(itemGuid, receiverGuid);
    _dataPassingService.addToDataPassingList("receiver_guid", receiverGuid);
    _dataPassingService.addToDataPassingList("chat_guid", result.guid);
    _chatService.sendMessage(
        itemGuid, receiverGuid, message, ChatMessageType.buyer_offer);
    _navigationService.navigateToView(ChatScreen());
  }

  Future<void> updateOrderStatus(String guid, OrderStatus status) async {
    await _orderService.updateOrderStatus(guid, status);
  }

  Future<void> updateItemStatus(String guid, ItemStatus status) async {
    await _itemService.updateItemStatusByGuid(guid, status);
  }

  void navigateToManageItemListingScreen() {
    _navigationService.popRepeated(3);
  }

  void navigateToUserProfileScreen(User seller) {
    _navigationService.navigateToView(UserProfileScreen(userGuid: seller.guid));
  }

}
