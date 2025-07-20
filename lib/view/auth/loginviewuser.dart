import 'package:bhc/view/auth/forgotpassword.dart';
import 'package:bhc/view/auth/privacy.dart';
import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view/auth/termsandconditions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../resources/components/appColors.dart';
import '../../resources/components/customTextField.dart';
import '../../utils/utils.dart';
import '../../view_model/auth_view_model.dart';
import '../bhc1/floor_selection.dart';
import 'forgotpassword.dart';

class LoginViewUser extends StatefulWidget {
  LoginViewUser({super.key});

  @override
  _LoginViewUserState createState() => _LoginViewUserState();
}

class _LoginViewUserState extends State<LoginViewUser> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showpass = true;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
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
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    cursorColor: Colors.black,
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

                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: passController,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onPressed: (){
                        setState(() {
                          showpass = !showpass;
                        });
                      }, icon: Icon(showpass?Icons.remove_red_eye_outlined:Icons.remove_red_eye)),
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
                      // Handle Forgot Password
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
                      onTap: () async {
                        final email = emailController.text.trim();
                        final password = passController.text.trim();

                        if (email.contains("@asr")) {
                          Fluttertoast.showToast(
                            msg: "This email belongs to an Admin",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          await authViewModel.login(email, password, context);
                        }
                      },
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
                  // Terms of Service
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
}
