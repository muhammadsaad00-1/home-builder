import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  // Future<dynamic>loginApi(dynamic data) async{
  //   try{
  //     dynamic response =await apiService.getPostApiResponse(AppUrl.loginEndPoint, data);
  //     return response;
  //   }
  //   catch(e){
  //     throw e;
  //   }
  // }
  // Future<dynamic>SignUpApi(dynamic data) async{
  //   try{
  //     dynamic response =await apiService.getPostApiResponse(AppUrl.registerApiEndPoint, data);
  //     return response;
  //   }
  //   catch(e){
  //     throw e;
  //   }
  // }

  Future<UserCredential> signUp(
      String email, String password, String name, BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential; // Ensure this is returned
    } catch (e) {
      rethrow; // Ensure the error propagates properly
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    try {
      final credentials = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return credentials;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
