import 'package:bhc/view/auth/privacy.dart';
import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view/auth/termsandconditions.dart';
import 'package:bhc/view_model/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../resources/components/appColors.dart';
import '../../view_model/auth_view_model.dart';

class SignupOptionsView extends StatefulWidget {
  const SignupOptionsView({super.key});

  @override
  State<SignupOptionsView> createState() => _SignupOptionsViewState();
}

class _SignupOptionsViewState extends State<SignupOptionsView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final authservice = AuthService();
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: w * 0.2,
              ),
              SizedBox(height: h * 0.12),

              /// **Sign Up with Email**
              _buildSignUpOption(
                icon: const Icon(Icons.email_rounded, size: 35),
                text: 'Sign up with email',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileCreationView()),
                  );
                },
              ),

              SizedBox(height: h * 0.03),

              /// **Sign Up with Google**
              _buildSignUpOption(
                icon: Image.asset('assets/images/google (2).png', height: 30),
                text: 'Sign up with Google',
                onTap: _isLoading ? null : _handleGoogleSignUp,
              ),

              SizedBox(height: h * 0.15),

              /// **Privacy Policy & Terms of Service**
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> PrivacyPolicyScreen()));
                },
                child: Text(
                  'Privacy policy',
                  style: GoogleFonts.poppins(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black87,
                    color: Colors.black87,
                    fontSize: 10,
                  ),
                ),
              ),
              SizedBox(height: h * 0.01),
              // Terms of Service
              GestureDetector(

                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> TermsConditionsScreen()));
                },
                child: Text(
                  'Terms of service',
                  style: GoogleFonts.poppins(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.black87,
                    color:Colors.black87,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  /// **Handle Google Sign Up**
  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Check if this is a new user or existing user
        final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

        if (isNewUser) {
          // Store user data in Firestore for new users
          await _storeUserDataInFirestore(user);

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Show welcome back message for existing users
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome back!'),
                backgroundColor: Colors.blue,
              ),
            );
          }
        }

        // Navigate to the next screen (you can replace this with your desired navigation)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ProfileCreationView()),
          );
        }
      }
    } catch (e) {
      // Handle errors
      print('Error during Google Sign Up: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// **Store User Data in Firestore**
  Future<void> _storeUserDataInFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'provider': 'google',
      }, SetOptions(merge: true));

      print('User data stored successfully in Firestore');
    } catch (e) {
      print('Error storing user data in Firestore: $e');
      throw e;
    }
  }

  /// **Reusable Method for Signup Options**
  Widget _buildSignUpOption(
      {required Widget icon,
        required String text,
        required VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 15),
              Text(
                text,
                style: GoogleFonts.poppins(color: appColors.greyy, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// **Reusable Method for Footer Text**
  Widget _buildFooterText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        decoration: TextDecoration.underline,
        decorationColor: Colors.black87,
        color: Colors.black87,
        fontSize: 10,
      ),
    );
  }
}