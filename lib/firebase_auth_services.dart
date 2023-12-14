
import 'package:firebase_auth/firebase_auth.dart';




class FirebaseAuthService {

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
          print("email-already-in-use aa");
        // Fluttertoast.showToast(msg: 'The email address is already in use.');
      } else {

        print("elsee aa");

        // Fluttertoast.showToast(msg: 'An error occurred: ${e.code}');
      }
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print("aa");

        // Fluttertoast.showToast(msg: 'Invalid email or password.');
      } else {
        print("aa");

        // Fluttertoast.showToast(msg: 'An error occurred: ${e.code}');
      }

    }
    return null;

  }




}