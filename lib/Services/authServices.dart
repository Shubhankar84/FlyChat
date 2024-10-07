import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fly_chat/Services/alertService.dart';
import 'package:fly_chat/models/user.dart' as model;  // Adjust the import based on your structure


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final AlertService _alertService = AlertService();  // Instance of AlertService

  AuthService();

  // Sign Up user with email and password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String mobileNo,
    required BuildContext context,  // Context needed for toast display
  }) async {
    try {
      // Create a new user with email and password
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firebase Auth User
      User? user = cred.user;
      print("user cretaed with email and password");

      if (user != null) {
        // Create a new user model and store in Firestore
        model.User newUser = model.User(
          uid: user.uid,
          name: name,
          email: email,
          password: password,  // Storing plain passwords is not recommended. Consider encrypting.
          mobileNo: mobileNo, 
        );

        // Save the user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

        // Show toast upon success
        // _alertService.showToast(
        //   text: "Sign up successful",
        //   context: context,
        //   icon: Icons.check_circle,
        // );

        print("User data stored");

        return true;
      }
    } on FirebaseAuthException catch (e) {
      // _alertService.showToast(
      //   text: e.message ?? 'Sign up failed',
      //   context: context,
      //   icon: Icons.error,
      // );
      print(e.message);
    }
    return false;
  }

  // Sign In user with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    required BuildContext context,  // Context needed for toast display
  }) async {
    try {
      // Sign in with email and password
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        // _alertService.showToast(
        //   text: "Sign in successful",
        //   context: context,
        //   icon: Icons.check_circle,
        // );
        print("User signin success");
        return true;
      }
    } on FirebaseAuthException catch (e) {
      // _alertService.showToast(
      //   text: e.message ?? 'Sign in failed',
      //   context: context,
      //   icon: Icons.error,
      // );
      print(e.message);
    }
    return false;
  }

  // Sign out the current user
  Future<void> signOut({
    required BuildContext context,  // Context needed for toast display
  }) async {
    try {
      await _auth.signOut();
      // _alertService.showToast(
      //   text: "Sign out successful",
      //   context: context,
      //   icon: Icons.logout,
      // );
    } catch (e) {
      // _alertService.showToast(
      //   text: "Error signing out",
      //   context: context,
      //   icon: Icons.error,
      // );
      print(e.toString());
    }
  }
}
