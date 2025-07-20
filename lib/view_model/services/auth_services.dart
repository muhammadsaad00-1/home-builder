import 'dart:developer';
import 'dart:io';
import 'package:bhc/view/bhc2/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../utils/utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign-in method
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Check internet connectivity
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        log('No internet connection');
        return null;
      }

      // Trigger authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        log('User cancelled Google Sign-In');
        return null;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Check if tokens are available
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        log('Failed to get Google authentication tokens');
        return null;
      }

      // Create a credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _storeUserInFirestore(user);
        log('Google Sign-In successful for user: ${user.email}');
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      log('Firebase Auth Error: ${e.code} - ${e.message}');
      _showErrorMessage(context, 'Firebase Auth Error: ${e.message}');
    } catch (e) {
      log('Google Sign-In Error: $e');
      _showErrorMessage(context, 'Sign-in failed. Please try again.');
    }
    return null;
  }

  // Store user credentials in Firestore
  Future<void> _storeUserInFirestore(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'name': user.displayName ?? "Unknown",
          'email': user.email ?? "No email",
          'profileImage': user.photoURL ?? "",
          'createdAt': FieldValue.serverTimestamp(),
        });
        log('User data stored in Firestore');
      } else {
        log('User already exists in Firestore');
      }
    } catch (e) {
      log('Error storing user in Firestore: $e');
    }
  }

  // Show error message to user
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle Google Sign-In and Navigation
  Future<void> handleGoogleButtonClick(BuildContext context) async {
    try {
      final userCredential = await signInWithGoogle(context);
      if (userCredential != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        log("Failed to create Account");
        _showErrorMessage(context, "Failed to sign in. Please try again.");
      }
    } catch (e) {
      log("Error in handleGoogleButtonClick: $e");
      _showErrorMessage(context, "An error occurred during sign-in.");
    }
  }

  // Sign out method
  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      Navigator.popUntil(context, (route) => route.isFirst);
      log("User signed out successfully");
    } catch (e) {
      log("Sign Out Error: $e");
      _showErrorMessage(context, "Error signing out. Please try again.");
    }
  }
}