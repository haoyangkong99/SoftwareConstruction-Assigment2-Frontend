import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/services.dart';
import 'package:utmletgo/constants/_constants.dart';
import 'package:utmletgo/model/ReviewsLink.dart';
import 'package:utmletgo/model/User.dart';
import 'package:utmletgo/model/StripeAccount.dart';
import 'package:utmletgo/services/_services.dart';
import 'package:utmletgo/shared/Exception.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

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

    String endpoint =
        'https://softcon-assignment-2-backend.onrender.com/api/user/add';

    try {
      final response = await http.post(Uri.parse(endpoint),
          body: jsonEncode({"uid": userID, "user": user.toMap()}),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
          });
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw auth.FirebaseException(
            code: jsonResponse['code'],
            message: jsonResponse['message'],
            plugin: '');
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when adding user", message: e.toString());
    }
  }

  Future<bool> updateUserByDocumentId(User user, String documentId) async {
    String endpoint =
        'https://softcon-assignment-2-backend.onrender.com/api/user/update-by-docId';

    try {
      final response = await http.put(Uri.parse(endpoint),
          body: jsonEncode({'docId': documentId, 'user': user.toMap()}),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
          });
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw auth.FirebaseException(
            code: jsonResponse['code'],
            message: jsonResponse['message'],
            plugin: '');
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when updating user", message: e.toString());
    }
  }

  Future<bool> updateUserByGuid(User user, String guid) async {
    String endpoint =
        'https://softcon-assignment-2-backend.onrender.com/api/user/update-by-guid';

    try {
      final response = await http.put(Uri.parse(endpoint),
          body: jsonEncode({'guid': guid, 'user': user.toMap()}),
          headers: {
            "Accept": "application/json",
            "content-type": "application/json",
          });
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw auth.FirebaseException(
            code: jsonResponse['code'],
            message: jsonResponse['message'],
            plugin: '');
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when updating user", message: e.toString());
    }
  }

  Future<bool> deleteUserByDocumentId(String documentId) async {
    return await dbService.deleteDocument(collectionPath, documentId);
  }

  Future<bool> deleteUserByGuid(String guid) async {
    return await dbService.deleteDocumentByGuid(collectionPath, guid);
  }

  Future<List<User>> getAllUsers() async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/user/get-all';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> userList = jsonResponse['user'];
        return userList.map((e) => User.fromMap(e)).toList();
      } else {
        throw GeneralException(
            title: jsonResponse['code'], message: jsonResponse['message']);
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when getting record", message: e.toString());
    }
  }

  Future<bool> validateDocumentExist(String documentId) {
    return dbService
        .readByDocumentId(collectionPath, documentId)
        .then((value) => value.exists);
  }

  Future<User> getUserByDocumentId(String documentId) async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/user/get-by-docId/${documentId}';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return User.fromMap(jsonResponse['user']);
      } else {
        throw GeneralException(
            title: jsonResponse['code'], message: jsonResponse['message']);
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when getting record", message: e.toString());
    }
  }

  Future<User> getUserByGuid(String? guid) async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/user/get-by-guid/${guid}';
    try {
      final response = await http.get(Uri.parse(url));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromMap(jsonResponse['user']);
      } else {
        throw GeneralException(
            title: jsonResponse['code'], message: jsonResponse['message']);
      }
    } catch (e) {
      throw GeneralException(
          title: "Error occured when getting record", message: e.toString());
    }
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
