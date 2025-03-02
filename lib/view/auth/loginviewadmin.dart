import 'package:bhc/view/auth/profile_creation.dart';
import 'package:bhc/view/sitebuilder/sitebuilderhomepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../resources/components/appColors.dart';
import '../../resources/components/customTextField.dart';
import '../../utils/utils.dart';
import '../../view_model/auth_view_model.dart';
import 'package:bhc/view/admin/portal.dart';

import '../admin/portal.dart';

class LoginViewAdmin extends StatelessWidget {
  LoginViewAdmin({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.05),
                  Center(
                      child:
                          Image.asset('assets/images/logo.png', height: 200)),
                  SizedBox(height: h * 0.01),
                  Text('Login',
                      style: GoogleFonts.roboto(
                          color: appColors.greyy,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: h * 0.03),
                  Text('Email address',
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 12)),
                  SizedBox(height: h * 0.01),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.black54, size: 35),
                        border: InputBorder.none,
                        hintText: "SiteBuilder@bhc.com",
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.black54, fontSize: 15),
                      ),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Text('Password',
                      style: GoogleFonts.poppins(
                          color: Colors.black54, fontSize: 12)),
                  SizedBox(height: h * 0.01),
                  customTextFields.defaultTextField(
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Kindly enter password";
                      }
                      return null;
                    },
                    obs: true,
                    hintText: "**********",
                    controller: passController,
                  ),
                  SizedBox(height: h * 0.01),
                  InkWell(
                    onTap: () {},
                    child: const Align(
                      alignment: Alignment.topRight,
                      child: Text("Forgot password?",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: appColors.orangee,
                              color: appColors.orangee,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                    ),
                  ),
                  SizedBox(height: h * 0.04),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                        onTap: () async {
                          final email = emailController.text.trim();
                          final password = passController.text.trim();

                          if (!email.contains("@bhc")) {
                            Fluttertoast.showToast(
                                msg: "This email belongs to a User",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM
                            );
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            await authViewModel.login(email, password, context);

                            if (authViewModel.isLoggedIn) {
                              // Add the email to Firestore under "sitebuilders"
                              try {
                                final siteBuildersCollection = FirebaseFirestore.instance.collection("sitebuilders");

                                // Check if the email already exists in the collection
                                final existingDocs = await siteBuildersCollection.where("email", isEqualTo: email).get();

                                if (existingDocs.docs.isEmpty) {
                                  await siteBuildersCollection.add({
                                    "email": email,
                                    "addedAt": FieldValue.serverTimestamp(),
                                  });
                                }

                                // Navigate to SiteBuilderHome
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SiteBuilderHome()),
                                );
                              } catch (e) {
                                Fluttertoast.showToast(
                                    msg: "Error adding to sitebuilders: ${e.toString()}",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM
                                );
                              }
                            }
                          }
                        },

                      child: Container(
                        height: 60,
                        width: w * 0.9,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: appColors.orangee,
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
                    children: [
                      const Expanded(child: Divider()),
                      const Text("Don't have an account?",
                          style: TextStyle(
                              color: appColors.orangee,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProfileCreationView()));
                        },
                        child: const Text("Sign up",
                            style: TextStyle(
                                color: appColors.orangee,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: h * 0.15),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Privacy policy',
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            decorationColor: appColors.orangee,
                            color: appColors.orangee,
                            fontSize: 10)),
                  ),
                  SizedBox(height: h * 0.01),
                  Align(
                    alignment: Alignment.center,
                    child: Text('Terms of service',
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            decorationColor: appColors.orangee,
                            color: appColors.orangee,
                            fontSize: 10)),
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
