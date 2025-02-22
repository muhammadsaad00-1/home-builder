import 'dart:developer';
import 'dart:io';

import 'package:bhc/view/bhc1/choose_facade.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utils/utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-in method
  Future<UserCredential?> signInWithGoogle() async {
    await InternetAddress.lookup('google.com');

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential? googleCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Once signed in, return the UserCredential
      return googleCredential;
    } catch (e) {
      log('Error in signup with google $e');

      return null;
    }
  }

  // creating google account
  handleGoogleButtonClick(context) async {
    try {
      final userCredential = await signInWithGoogle();
      if (userCredential != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ChooseFacadeView()));
      } else {
        log("Failed to create Account");
        Utils.snackBar("Authentication failed. Please try again", context);
      }
    } catch (e) {
      log("Error in signup with google: $e");
      Utils.snackBar("An error occurred. Please try again", context);
    }
  }
}
  // Store user credentials in Firestore

  // Sign out from Google
  // Future<void> signOutGoogle(context) async {
  //   await _googleSignIn.signOut();
  //   await _auth.signOut();
  //   await FirebaseAuth.instance.signOut();
  // //  Navigator.pushNamed(context, routesName.login);
  // }

// signOut(context)async{
//   Utils.flushBarErrorMessage("Logging Out...",context);
//   try{
//     await FirebaseAuth.instance.signOut();
//     Navigator.popUntil(context, (route) => route.isFirst);
//     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>loginView()));
//     log("Logged out log");
//   }
//   catch(e){
//     // VxToast.show(context, msg: e.toString());
//   }
// }
