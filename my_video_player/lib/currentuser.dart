import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CurrentUser extends ChangeNotifier {
  late String _uid;
  late String _email;

  String get getUid => _uid;
  String get getEmail => _email;

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signUpUser(String email, String password) async {
    try {
      UserCredential _authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _authResult.user != null; 
    } catch (e) {
      print('SignUp Error: $e');
      return false; 
    }
  }

  Future<bool> logInUser(String email, String password) async {
    try {
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_authResult.user != null) {
        _uid = _authResult.user!.uid;
        _email = _authResult.user!.email!;
        return true; 
      }
      return false; 
    } catch (e) {
      print('LogIn Error: $e');
      return false; 
    }
  }
}
