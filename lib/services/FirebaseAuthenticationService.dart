import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String getUID() {
    return _auth.currentUser!.uid;
  }

  Future<User?> signIn(String email, String password) async {
    User? user;
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      user = result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw FirebaseAuthException(
            code: 'ERROR_SIGN_IN_EMAIL_PASSWORD',
            message: 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw FirebaseAuthException(
            code: 'ERROR_SIGN_IN_EMAIL_PASSWORD',
            message: 'No user found for that email.');
      }
    }
    return user;
  }

  Future<UserCredential> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Get the Google Authentication credential
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        // Sign in to Firebase with the Google Authentication credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential;
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: 'ERROR_SIGN_IN_WITH_SOCIAL_MEDIA',
        message: e.message,
      );
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw FirebaseAuthException(
            code: 'ERROR_SIGN_UP_EMAIL_PASSWORD',
            message: 'The password provided is too weak');
      } else if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
            code: 'ERROR_SIGN_UP_EMAIL_PASSWORD',
            message: 'The account already exists for that email.');
      }
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
          code: 'ERROR_RESET_PASSWORD', message: e.message);
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
