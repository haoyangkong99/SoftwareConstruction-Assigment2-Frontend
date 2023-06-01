import 'dart:io';

import 'package:flutter/services.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/ReviewsLink.dart';
import 'package:utmletgo/model/User.dart';
import 'package:utmletgo/model/StripeAccount.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:uuid/uuid.dart';

class UserService {
  FirebaseDbService dbService = FirebaseDbService();
  FirebaseAuthenticationService authService = FirebaseAuthenticationService();
  FirebaseStorageService storageService = FirebaseStorageService();
  String collectionPath = "user";
  Future<bool> addUser(
    String userID,
    String email,
    String name,
    String gender,
    String status,
    String campus,
    String contact,
  ) async {
    var guid = const Uuid().v4();
    final ByteData assetByteData = await rootBundle.load(
        gender == Gender.Male.name
            ? 'assets/images/man profile icon.png'
            : 'assets/images/lady profile icon.png');
    final Uint8List assetBytes = assetByteData.buffer.asUint8List();
    final Directory tempDir = Directory.systemTemp;
    final File tempFile = File('${tempDir.path}/default profile icon.png');

    await tempFile.writeAsBytes(assetBytes);

    String url = await storageService.uploadImageToStorage(tempFile);
    User user = User.complete(
        guid,
        email,
        UserType.user.name,
        name,
        gender,
        status,
        campus,
        contact,
        VisibilityType.allow.name,
        url,
        List.empty(),
        ReviewsLink(),
        List.empty());

    return await dbService.addDocument(collectionPath, userID, user.toMap());
  }

  Future<bool> updateUserByDocumentId(User user, String documentId) async {
    return await dbService.updateDocumentByDocumentId(
        collectionPath, documentId, user.toMap());
  }

  Future<bool> updateUserByGuid(User user, String guid) async {
    return await dbService.updateDocumentByGuid(
        collectionPath, guid, user.toMap());
  }

  Future<bool> deleteUserByDocumentId(String documentId) async {
    return await dbService.deleteDocument(collectionPath, documentId);
  }

  Future<bool> deleteUserByGuid(String guid) async {
    return await dbService.deleteDocumentByGuid(collectionPath, guid);
  }

  Future<List<User>> getAllUsers() {
    return dbService.readAllDocument(collectionPath).then((value) =>
        value.docs.map((user) => User.fromMap(user.data())).toList());
  }

  Future<bool> validateDocumentExist(String documentId) {
    return dbService
        .readByDocumentId(collectionPath, documentId)
        .then((value) => value.exists);
  }

  Future<User> getUserByDocumentId(String documentId) {
    return dbService.readByDocumentId(collectionPath, documentId).then((value) {
      return User.fromMap(value.data());
    });
  }

  Future<User> getUserByGuid(String? guid) {
    return dbService.readByGuid(collectionPath, guid!).then((value) => value
        .docs
        .map((user) => User.fromMap(user.data()))
        .toList()
        .elementAt(0));
  }

  Future<String> getUserDocumentID(String? guid) {
    return dbService
        .readByGuid(collectionPath, guid!)
        .then((value) => value.docs.first.id);
  }

  Future<List<User>> getUserWithCondition(bool Function(User) condition) {
    return dbService.readAllDocument(collectionPath).then((value) => value.docs
        .map((e) => User.fromMap(e.data()))
        .where(condition)
        .toList());
  }

  Stream<List<User>> getAllUsersAsStream() {
    return dbService
        .readAllDocumentAsStream(collectionPath)
        .map((event) => event.docs.map((e) => User.fromMap(e.data())).toList());
  }

  Stream<User> getUserByDocumentIdAsStream(String documentId) {
    return dbService
        .readByDocumentIdAsStream(collectionPath, documentId)
        .map((event) => User.fromMap(event.data()));
  }

  Stream<User> getUserByGuidAsStream(String guid) {
    return dbService.readByGuidAsStream(collectionPath, guid).map(
        (event) => event.docs.map((e) => User.fromMap(e.data())).elementAt(0));
  }

  Stream<List<User>> getUserWithConditionAsStream(
      bool Function(User) condition) {
    return dbService.readAllDocumentAsStream(collectionPath).map((event) =>
        event.docs
            .map((e) => User.fromMap(e.data()))
            .where(condition)
            .toList());
  }

  Future<User> getCurrentUser() async {
    return getUserByDocumentId(authService.getUID());
  }

  Stream<User> getCurrentUserAsStream() {
    return getUserByDocumentIdAsStream(authService.getUID());
  }
}
