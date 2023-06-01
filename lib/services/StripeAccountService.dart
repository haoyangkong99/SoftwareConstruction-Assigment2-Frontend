import 'package:utmletgo/model/StripeAccount.dart';
import 'package:utmletgo/model/StripeAccountLinks.dart';
import 'package:utmletgo/services/_services.dart';

class StripeAccountService {
  FirebaseDbService dbService = FirebaseDbService();
  String accountDocumentPath = "account";
  String accountLinkDocumentPath = 'accountLinks';
  UserService userService = UserService();
  FirebaseAuthenticationService authenticationService =
      FirebaseAuthenticationService();

  Future<StripeAccount> getAccount(String userGuid) async {
    String documentID = await userService.getUserDocumentID(userGuid);
    return dbService
        .readByDocumentId("user/$documentID/stripe", accountDocumentPath)
        .then((value) => StripeAccount.fromMap(value.data()));
  }

  Stream<StripeAccount> getAccountAsStream() {
    String documentID = authenticationService.getUID();
    return dbService
        .readByDocumentIdAsStream(
            "user/$documentID/stripe", accountDocumentPath)
        .map((event) => StripeAccount.fromMap(event.data()));
  }

  Future<StripeAccountLinks> getAccountLink(String userGuid) async {
    String documentID = await userService.getUserDocumentID(userGuid);
    return dbService
        .readByDocumentId("user/$documentID/stripe", accountLinkDocumentPath)
        .then((value) => StripeAccountLinks.fromMap(value.data()));
  }

  Stream<StripeAccountLinks> getAccountLinkAsStream() {
    String documentID = authenticationService.getUID();
    return dbService
        .readByDocumentIdAsStream(
            "user/$documentID/stripe", accountLinkDocumentPath)
        .map((event) => StripeAccountLinks.fromMap(event.data()));
  }

  Future<bool> updateAccountLinksByDocumentId(
      StripeAccountLinks link, String documentId) async {
    String documentID = authenticationService.getUID();
    return await dbService.updateDocumentByDocumentId(
        "user/$documentID/stripe", accountLinkDocumentPath, link.toMap());
  }
}
