import 'package:bhc/view/auth/forgotpassword.dart';
import 'package:bhc/view/auth/privacy.dart';
import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view/auth/termsandconditions.dart';
import 'package:bhc/view/bhc2/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewUser extends StatefulWidget {
  LoginViewUser({super.key});

  @override
  _LoginViewUserState createState() => _LoginViewUserState();
}

class _LoginViewUserState extends State<LoginViewUser> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showpass = true;
  bool isLoading = false;

  // Firebase login method
  Future<void> _loginWithFirebase() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showToast("Please fill in all fields", Colors.red);
      return;
    }

    if (email.contains("@asr")) {
      _showToast("This email belongs to an Admin", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Check if email is verified
        if (!user.emailVerified) {
          // Send verification email
          await user.sendEmailVerification();

          _showToast(
            "Please verify your email. A verification link has been sent to your email address.",
            Colors.grey,
          );

          // Sign out the user since email is not verified
          await _auth.signOut();
          return;
        }

        // Email is verified, proceed with login
        _showToast("Login successful!", Colors.black87);

        // Navigate to the main screen (adjust route as needed)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeView()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for that email.";
          break;
        case 'wrong-password':
          errorMessage = "Wrong password provided.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is badly formatted.";
          break;
        case 'user-disabled':
          errorMessage = "This user account has been disabled.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many unsuccessful login attempts. Please try again later.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = "An error occurred. Please try again.";
      }
      _showToast(errorMessage, Colors.red);
    } catch (e) {
      _showToast("An unexpected error occurred. Please try again.", Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Custom toast method with gray background for email verification
  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
      timeInSecForIosWeb: 1

    );
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: h,
            width: w,
            padding: EdgeInsets.symmetric(horizontal: w*0.06),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.05),
                  Center(
                    child: Image.asset('assets/images/logo.png', height: w*0.2),
                  ),
                  SizedBox(height: h * 0.08),
                  SizedBox(height: h * 0.03),
                  Text('Email address',
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 12)),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "User@gmail.com",
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.4), fontSize: 15),
                    ),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  SizedBox(height: h * 0.02),
                  Text('Password',
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 12)),
                  TextFormField(
                    controller: passController,
                    cursorColor: Colors.black,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onPressed: (){
                            setState(() {
                              showpass = !showpass;
                            });
                          }, icon: Icon(showpass?Icons.visibility_off:Icons.visibility)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      hintText: "********",
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.withOpacity(0.4), fontSize: 15),
                    ),
                    style: GoogleFonts.poppins(fontSize: 12),
                    obscureText: showpass,
                  ),

                  SizedBox(height: h * 0.01),
                  InkWell(
                    splashColor: Colors.transparent,
                    overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordView()));
                    },
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black87,
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          await _loginWithFirebase();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: w * 0.9,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey : Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            "Log in",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const ProfileCreationView()),
                          );
                        },
                        child: const Text("Sign up",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.15),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
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
                  ),
                  SizedBox(height: h * 0.01),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }
}