import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:utmletgo/shared/Exception.dart';
import 'package:utmletgo/constants/_constants.dart';

class FirebaseAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getUID() {
    return currentUserUid;
  }

  Future<String> signIn(String email, String password) async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/auth/login-email';

    Map<String, String> body = {"email": email, "password": password};

    final response =
        await http.post(Uri.parse(url), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      currentUserUid = jsonResponse['uid'];

      return jsonResponse['uid'] as String;
    } else {
      throw FirebaseAuthException(
          code: jsonResponse['code'], message: jsonResponse['message']);
    }
  }

  Future<bool> signUp(String email, String password) async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/auth/register';
    Map<String, String> body = {"email": email, "password": password};

    final response =
        await http.post(Uri.parse(url), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });
    final jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      currentUserUid = jsonResponse['uid'];
      return true;
    } else {
      throw FirebaseAuthException(
          code: jsonResponse['code'], message: jsonResponse['message']);
    }
  }

  Future<bool> resetPassword(String email) async {
    String url =
        'https://softcon-assignment-2-backend.onrender.com/api/auth/reset';

    Map<String, String> body = {"email": email};
    final response =
        await http.post(Uri.parse(url), body: jsonEncode(body), headers: {
      "Accept": "application/json",
      "content-type": "application/json",
    });

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw FirebaseAuthException(
          code: jsonResponse['code'], message: jsonResponse['message']);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw FirebaseAuthException(
          code: 'ERROR_SIGN_OUT', message: error.message);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser!.delete();
    } on FirebaseAuthException catch (error) {
      throw FirebaseAuthException(
          code: 'ERROR_DELETE_ACC', message: error.message);
    }
  }
}
