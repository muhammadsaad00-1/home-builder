import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view_model/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../resources/components/appColors.dart';
import '../../view_model/auth_view_model.dart';

class SignupOptionsView extends StatefulWidget {
  const SignupOptionsView({super.key});

  @override
  State<SignupOptionsView> createState() => _SignupOptionsViewState();
}

class _SignupOptionsViewState extends State<SignupOptionsView> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final authservice = AuthService();
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: w*0.2,
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
            onTap: () async {
              await authservice.handleGoogleButtonClick(context);
            },
          ),

          SizedBox(height: h * 0.15),

          /// **Privacy Policy & Terms of Service**
          _buildFooterText('Privacy policy'),
          SizedBox(height: h * 0.01),
          _buildFooterText('Terms of service'),
        ],
      ),
    );
  }

  /// **Reusable Method for Signup Options**
  Widget _buildSignUpOption(
      {required Widget icon,
      required String text,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: InkWell(
        onTap: onTap,
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
    );
  }

  /// **Reusable Method for Footer Text**
  Widget _buildFooterText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        decoration: TextDecoration.underline,
        decorationColor: Colors.black87,
        color:Colors.black87,
        fontSize: 10,
      ),
    );
  }
}
