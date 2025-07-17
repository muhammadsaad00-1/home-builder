import 'dart:io';
import 'package:bhc/view/auth/loginviewuser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../resources/components/appColors.dart';
import '../../resources/components/customTextField.dart';
import '../../utils/utils.dart';
import '../../view_model/auth_view_model.dart';
import 'loginfather.dart';

class ProfileCreationView extends StatefulWidget {
  const ProfileCreationView({super.key});

  @override
  State<ProfileCreationView> createState() => _ProfileCreationViewState();
}

class _ProfileCreationViewState extends State<ProfileCreationView> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool showPass = true;


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: w*0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.1),
                Center(
                  child: Image.asset('assets/images/logo.png', height: w*0.2),
                ),
                SizedBox(height: h * 0.1),
                _buildTextField(
                   false, 'Full name', nameController, Icons.perm_identity_sharp),
                _buildTextField(
                    false,'Email address', emailController, Icons.email_outlined),
                _buildTextField(true, "Password", passController, Icons.import_contacts_sharp)     ,
                _buildTextField(false,'Phone number', contactController, Icons.phone,
                    keyboardType: TextInputType.number),
                SizedBox(height: h * 0.04),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () async {
                      final email = emailController.text.trim();
                      final name = nameController.text.trim();
                      final password = passController.text.trim();
                      final contact = contactController.text.trim();
                      await authViewModel.signup(
                          email, password, name, contact, context);
                      Utils.flushBarErrorMessage(
                          'Account created successfully', context);
                    },
                    child: Container(
                      height: 60,
                      width: w * 0.9,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      )),
                    ),
                  ),
                ),
                SizedBox(height: h * 0.02), // **Now it's correctly placed**

                Row(
                  children: [
                    const Expanded(child: Divider()),
                    const Text("Already have an account?",
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
                                  builder: (context) => LoginViewUser()));
                        },
                        child: const Text("Login",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w600))),
                    const Expanded(child: Divider()),
                  ],
                ),
                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      bool isPassword,String label, TextEditingController controller, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
        const SizedBox(height: 5),
        if(!isPassword)
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black54.withOpacity(0.5))),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              border: InputBorder.none,
              hintText: label,
              hintStyle:
                  GoogleFonts.poppins(color: Colors.grey.withOpacity(0.4), fontWeight: FontWeight.w300,fontSize: 15),
            ),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        if(isPassword)
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black54.withOpacity(0.5))),
            child: TextField(

              controller: controller,
              obscureText: showPass,
              keyboardType: keyboardType,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                suffixIcon:  IconButton(onPressed: (){
                  setState(() {
                    showPass =!showPass;
                  });
                }, icon: showPass?Icon(Icons.remove_red_eye_outlined): Icon(Icons.remove_red_eye)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical:12),
                border: InputBorder.none,
                hintText: label,
                hintStyle:
                GoogleFonts.poppins(color: Colors.grey.withOpacity(0.4), fontWeight: FontWeight.w300,fontSize: 15),
              ),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),

        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 12)),
        const SizedBox(height: 10),
        customTextFields.defaultTextField(
          validator: (val) => val!.isEmpty ? "Kindly enter password" : null,
          obs: true,
          hintText: "**********",
          controller: passController,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
