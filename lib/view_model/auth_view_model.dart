import 'package:bhc/view/bhc2/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repo/authRepo.dart';
import '../utils/utils.dart';

class AuthViewModel with ChangeNotifier {
  final repo = AuthRepository();
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _user;
  int currentTab = 0;

  User? get user => _user;

  AuthViewModel() {
    auth.authStateChanges().listen((User? user) async {
      _user = user;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', user != null);
    });
  }

  bool get isLoggedIn => _user != null;

  Future<void> sendPasswordResetLink(String email) async {
    try{
      await auth.sendPasswordResetEmail(email: email);

    }catch(e){
      print(e);
    }
  }

  /// **Sign Up and Create User Document in Firestore**
  Future<void> signup(String email, String password, String name,
      String contact, BuildContext context) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty || contact.isEmpty) {
      Utils.snackBar('Please fill in all fields', context);
      return;
    }

    try {
      UserCredential userCredential =
          await repo.signUp(email, password, name, context);

      if (userCredential.user != null) {
        _user = userCredential.user;
        await _createUserInFirestore(_user!.uid, name, email, contact);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        notifyListeners();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomeView()));
      }
    } catch (e) {
      Utils.snackBar('Signup failed: ${e.toString()}', context);
    }
  }

  /// **Create User Document in Firestore**
  Future<void> _createUserInFirestore(
      String userId, String name, String email, String contact) async {
    DocumentReference userDoc = _firestore.collection('users').doc(userId);

    try {
      DocumentSnapshot snapshot = await userDoc.get();
      if (!snapshot.exists) {
        await userDoc.set({
          'userId': userId,
          'name': name,
          'email': email,
          'contact': contact,
          'createdAt': FieldValue.serverTimestamp(),
          'projects': [],
        });
      }
    } catch (e) {
      print("Error creating user in Firestore: $e");
    }
  }

  /// **Login and Fetch User Data**
  Future<void> login(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      Utils.snackBar('Please fill in all fields', context);
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (userCredential.user != null) {
        _user = userCredential.user;

        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(_user!.uid).get();
        if (!userDoc.exists) {
          await _createUserInFirestore(_user!.uid, "Unknown", email, "");
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeView()));
          Utils.snackBar('Logged in successfully', context);
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.snackBar('No user found for that email.', context);
      } else if (e.code == 'wrong-password') {
        Utils.snackBar('Wrong password provided.', context);
      } else {
        Utils.snackBar(e.message ?? 'An error occurred', context);
      }
    } catch (e) {
      Utils.snackBar('An error occurred. Please try again.', context);
    }
  }

  /// **Logout and Clear Login State**
  Future<void> logout(BuildContext context) async {
    try {
      await auth.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      _user = null;
      notifyListeners();
      Navigator.pushReplacementNamed(context, '/initial');
    } catch (e) {
      Utils.snackBar('Logout failed: ${e.toString()}', context);
    }
  }

  void changeActiveTab(int index) {
    currentTab = index;
    notifyListeners();
  }
}
