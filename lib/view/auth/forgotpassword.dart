import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../resources/components/appColors.dart';
import '../../view_model/auth_view_model.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter your email");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
          msg: "Password reset email sent! Check your inbox.");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/images/logo.png', height: w*0.2),
                  ),
                  SizedBox(height: h * 0.15),
                  Text('Forgot Password',
                      style: GoogleFonts.roboto(
                          color: appColors.greyy,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: h * 0.03),
                  Text('Enter your email address',
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 12)),
                  SizedBox(height: h * 0.01),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "User@gmail.com",
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 15),
                    ),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  SizedBox(height: h * 0.04),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _resetPassword,
                      child: Container(
                        height: 60,
                        width: w * 0.9,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Send Reset Email",
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
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Back to Login",
                          style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
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
}
