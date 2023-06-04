import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utmletgo/constants/enum_constants.dart';
import 'package:utmletgo/model/_model.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:uuid/uuid.dart';
import 'package:utmletgo/model/Order.dart' as order;

class ItemService {
  FirebaseDbService dbService = FirebaseDbService();
  FirebaseAuthenticationService authService = FirebaseAuthenticationService();
  String collectionPath = "item";
  UserService userService = UserService();
  Future<void> addItem(
      String coverImage,
      String category,
      String subcategory,
      String condition,
      String title,
      String description,
      String location,
      String status,
      String postedDT,
      String visibility,
      List<String> images,
      List<String> paymentMethods,
      double price,
      int quantity) async {
    var guid = const Uuid().v4();
    Item item = Item.complete(
        guid,
        coverImage,
        category,
        subcategory,
        condition,
        title,
        description,
        location,
        status,
        postedDT,
        visibility,
        images,
        paymentMethods,
        price,
        quantity,
        ReviewsLink());

    await dbService
        .addDocumentWithRandomDocId(collectionPath, item.toMap())
        .then((value) async {
      await userService.getUserByDocumentId(authService.getUID()).then((user) {
        List<String>? itemLinks = user.itemLink;
        itemLinks.add(guid);
        user.itemLink = itemLinks;
        userService.updateUserByDocumentId(user, authService.getUID());
      });
    });
  }

  Future<void> updateItem(
      String guid,
      String coverImage,
      String category,
      String subcategory,
      String condition,
      String title,
      String description,
      String location,
      List<String> images,
      List<String> paymentMethods,
      double price,
      int quantity) async {
    Item item = await getItemByGuid(guid);
    item.coverImage = coverImage;
    item.category = category;
    item.subcategory = subcategory;
    item.condition = condition;
    item.title = title;
    item.description = description;
    item.location = location;
    item.images = images;
    item.paymentMethods = paymentMethods;
    item.price = price;
    item.quantity = quantity;
    await updateItemByGuid(item, guid);
  }

  Future<void> updateItemStatusByGuid(String guid, ItemStatus status) async {
    Item item = await getItemByGuid(guid);
    item.status = status.name;
    await updateItemByGuid(item, guid);

    if (status.name == ItemStatus.completed.name) {
      FirebaseFirestore db = FirebaseFirestore.instance;

      order.Order updateOrder = await db
          .collection("order")
          .where('itemGuid', isEqualTo: guid)
          .get()
          .then((value) => value.docs.map((e) => order.Order.fromMap(e.data())))
          .then((value) => value.where(
              (element) => element.status == OrderStatus.in_progress.name))
          .then((value) => value.first);

      updateOrder.status = OrderStatus.completed.name;
      await dbService.updateDocumentByGuid(
          "order", updateOrder.guid, updateOrder.toMap());
    }
  }

  Future<bool> updateItemByDocumentId(Item item, String documentId) async {
    return await dbService.updateDocumentByDocumentId(
        collectionPath, documentId, item.toMap());
  }

  Future<bool> updateItemByGuid(Item item, String guid) async {
    return await dbService.updateDocumentByGuid(
        collectionPath, guid, item.toMap());
  }

  Future<bool> deleteItemByDocumentId(String documentId) async {
    return await dbService.deleteDocument(collectionPath, documentId);
  }

  Future<bool> deleteItemByGuid(String guid) async {
    return await dbService.deleteDocumentByGuid(collectionPath, guid);
  }

  Future<List<Item>> getAllItems({bool visibility = true}) {
    return dbService.readAllDocument(collectionPath).then((value) =>
        value.docs.map((item) => Item.fromMap(item.data())).toList());
  }

  Future<Item> getItemByDocumentId(String documentId,
      {bool? visibility = true}) {
    return dbService
        .readByDocumentId(collectionPath, documentId)
        .then((value) => Item.fromMap(value.data()));
  }

  Future<Item> getItemByGuid(String guid, {bool? visibility = true}) {
    return dbService.readByGuid(collectionPath, guid).then((value) =>
        value.docs.map((item) => Item.fromMap(item.data())).elementAt(0));
  }

  Future<List<Item>> getItemWithCondition(bool Function(Item) condition,
      {bool? visibility = true}) {
    return dbService.readAllDocument(collectionPath).then((value) => value.docs
        .map((e) => Item.fromMap(e.data()))
        .where(condition)
        .toList());
  }

  Stream<List<Item>> getAllItemsAsStream({bool visibility = true}) {
    try {
      return dbService.readAllDocumentAsStream(collectionPath).map((event) {
        if (event.docs.isEmpty) {
          return [];
        } else {
          return event.docs.map((e) {
            return Item.fromMap(e.data());
          }).where((element) {
            return visibility
                ? element.visibility == VisibilityType.allow.name
                : (element.visibility == VisibilityType.allow.name ||
                    element.visibility == VisibilityType.disallow.name);
          }).toList();
        }
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Stream<Item> getItemByDocumentIdAsStream(String documentId,
      {bool visibility = true}) {
    return dbService
        .readByDocumentIdAsStream(collectionPath, documentId)
        .map((event) => Item.fromMap(event.data()));
  }

  Stream<Item> getItemByGuidAsStream(String guid, {bool visibility = true}) {
    return dbService
        .readByGuidAsStream(collectionPath, guid)
        .map((event) => event.docs.map((e) => Item.fromMap(e.data())).first);
  }

  Stream<List<Item>> getItemWithConditionAsStream(
    bool Function(Item) condition,
  ) {
    return dbService.readAllDocumentAsStream(collectionPath).map((event) =>
        event.docs
            .map((e) => Item.fromMap(e.data()))
            .where(condition)
            .toList());
  }
}
