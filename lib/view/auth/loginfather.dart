import 'package:bhc/view/auth/loginviewadmin.dart';
import 'package:bhc/view/auth/loginviewuser.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../resources/components/appColors.dart';

class LoginFather extends StatefulWidget {
  const LoginFather({super.key});

  @override
  State<LoginFather> createState() => _LoginFatherState();
}

class _LoginFatherState extends State<LoginFather> {
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
            height: w*0.2,
          ),
          SizedBox(height: h * 0.1),
          // Login as User
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person,
                      size: 35,
                    ),
                    SizedBox(width: w * 0.06),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginViewUser()),
                        );
                      },
                      child: Text(
                        'Login as User',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          color: appColors.greyy,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.03),
                // Login as Admin
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/adminicon.png',
                      height: 30,
                    ),
                    SizedBox(width: w * 0.06),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginViewAdmin()),
                        );
                      },
                      child: Text(
                        'Login as Site Builder',
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                          color: appColors.greyy,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
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
              decorationColor: Colors.black87,
              color: Colors.black87,
              fontSize: 10,
            ),
          ),
          SizedBox(height: h * 0.01),
          // Terms of Service
          Text(
            'Terms of service',
            style: GoogleFonts.poppins(
              decoration: TextDecoration.underline,
              decorationColor: Colors.black87,
              color: Colors.black87,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
