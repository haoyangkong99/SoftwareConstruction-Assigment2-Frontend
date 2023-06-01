import 'package:utmletgo/app/route.locator.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:uuid/uuid.dart';

class OrderService {
  FirebaseDbService dbService = FirebaseDbService();
  String collectionPath = "order";
  final userService = locator<UserService>();
  final itemService = locator<ItemService>();
  Future<void> addOrder(String offerGuid, String itemGuid, double amount,
      Address shippingAddress, Payment payment, String sellerGuid) async {
    var guid = const Uuid().v4();
    String buyerGuid =
        await userService.getCurrentUser().then((value) => value.guid);
    Order order = Order.complete(
        guid: guid,
        offerGuid: offerGuid,
        itemGuid: itemGuid,
        status: OrderStatus.in_progress.name,
        amount: amount,
        payment: payment,
        shippingAddress: shippingAddress,
        buyerGuid: buyerGuid,
        sellerGuid: sellerGuid);

    await dbService.addDocumentWithRandomDocId(collectionPath, order.toMap());
    Item item = await itemService.getItemByGuid(itemGuid);
    item.status = ItemStatus.in_progress.name;
    await itemService.updateItemByGuid(item, itemGuid);
  }

  Future<bool> validateOrderExist(Offer offer) async {
    var result = await getOrderWithCondition((order) =>
        order.itemGuid == offer.itemGuid &&
        order.status != OrderStatus.cancelled.name);

    return result.isNotEmpty;
  }

  Future<void> updateOrderStatus(String guid, OrderStatus status) async {
    Order order = await getOrderByGuid(guid);
    order.status = status.name;
    Item item = await itemService.getItemByGuid(order.itemGuid);
    bool needUpdate = false;

    await updateOrderByGuid(order, guid);
    switch (status) {
      case OrderStatus.completed:
        item.status = ItemStatus.completed.name;
        needUpdate = true;
        break;
      case OrderStatus.cancelled:
        item.status = ItemStatus.to_start.name;
        needUpdate = true;
        break;
      default:
        break;
    }

    if (needUpdate) {
      await itemService.updateItemByGuid(item, item.guid);
    }
  }

  Future<bool> updateOrderByDocumentId(Order order, String documentId) async {
    return await dbService.updateDocumentByDocumentId(
        collectionPath, documentId, order.toMap());
  }

  Future<bool> updateOrderByGuid(Order order, String guid) async {
    return await dbService.updateDocumentByGuid(
        collectionPath, guid, order.toMap());
  }

  Future<bool> deleteOrderByDocumentId(String documentId) async {
    return await dbService.deleteDocument(collectionPath, documentId);
  }

  Future<bool> deleteOrderByGuid(String guid) async {
    return await dbService.deleteDocumentByGuid(collectionPath, guid);
  }

  Future<List<Order>> getAllOrders({bool visibility = true}) {
    return dbService.readAllDocument(collectionPath).then((value) =>
        value.docs.map((order) => Order.fromMap(order.data())).toList());
  }

  Future<Order> getOrderByDocumentId(
    String documentId,
  ) {
    return dbService
        .readByDocumentId(collectionPath, documentId)
        .then((value) => Order.fromMap(value.data()));
  }

  Future<Order> getOrderByGuid(
    String guid,
  ) {
    return dbService.readByGuid(collectionPath, guid).then((value) =>
        value.docs.map((order) => Order.fromMap(order.data())).elementAt(0));
  }

  Future<List<Order>> getOrderWithCondition(
    bool Function(Order) condition,
  ) {
    return dbService.readAllDocument(collectionPath).then((value) => value.docs
        .map((e) => Order.fromMap(e.data()))
        .where(condition)
        .toList());
  }

  Stream<List<Order>> getAllOrdersAsStream() {
    return dbService.readAllDocumentAsStream(collectionPath).map(
        (event) => event.docs.map((e) => Order.fromMap(e.data())).toList());
  }

  Stream<Order> getOrderByDocumentIdAsStream(String documentId,
      {bool visibility = true}) {
    return dbService
        .readByDocumentIdAsStream(collectionPath, documentId)
        .map((event) => Order.fromMap(event.data()));
  }

  Stream<Order> getOrderByGuidAsStream(String guid, {bool visibility = true}) {
    return dbService.readByGuidAsStream(collectionPath, guid).map(
        (event) => event.docs.map((e) => Order.fromMap(e.data())).elementAt(0));
  }

  Stream<List<Order>> getOrderWithConditionAsStream(
    bool Function(Order) condition,
  ) {
    var result = dbService.readAllDocumentAsStream(collectionPath).map(
        (event) => event.docs
            .map((e) => Order.fromMap(e.data()))
            .where(condition)
            .toList());

    return result;
  }
}
