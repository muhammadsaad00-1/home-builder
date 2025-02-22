import 'package:bhc/view/auth/profile_creation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';
import '../../view_model/services/auth_services.dart';

class SignupOptionsView extends StatefulWidget {
  const SignupOptionsView({super.key});

  @override
  State<SignupOptionsView> createState() => _SignupOptionsViewState();
}

class _SignupOptionsViewState extends State<SignupOptionsView> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 200,
          ),
          SizedBox(height: h * 0.03),
          // Sign up with Email
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.email_rounded,
                  size: 35,
                ),
                SizedBox(width: w * 0.06),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileCreationView(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign up with email',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      color: appColors.greyy,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.03),
          // Sign up with Google
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google (2).png',
                  height: 30,
                ),
                SizedBox(width: w * 0.06),
                TextButton(
                  onPressed: () {
                    authService.handleGoogleButtonClick(context);
                  },
                  child: Text(
                    'Sign up with Google',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      color: appColors.greyy,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.15),
          // Privacy Policy
          Text(
            'Privacy policy',
            style: GoogleFonts.poppins(
              decoration: TextDecoration.underline,
              decorationColor: appColors.orangee,
              color: appColors.orangee,
              fontSize: 10,
            ),
          ),
          SizedBox(height: h * 0.01),
          // Terms of Service
          Text(
            'Terms of service',
            style: GoogleFonts.poppins(
              decoration: TextDecoration.underline,
              decorationColor: appColors.orangee,
              color: appColors.orangee,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
