import 'package:bhc/view/auth/loginfather.dart';
import 'package:bhc/view/auth/privacy.dart';
import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view/auth/signUp_options.dart';
import 'package:bhc/view/auth/termsandconditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../resources/components/appColors.dart';
import '../../view_model/services/auth_services.dart';
import 'loginviewuser.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop(); // Closes the app smoothly
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: w*0.2,
              ),
              SizedBox(height: h * 0.1),
              // Sign Up Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                child: InkWell(
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupOptionsView()));
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Sign Up",
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
              // Login Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.1),
                child: InkWell(
                  onTap: () async {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginFather()));
                    // Add login logic here
                  },
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "Login",
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
              SizedBox(height: h * 0.15),
              // Privacy Policy
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
        ),
      ),
    );
  }
}
