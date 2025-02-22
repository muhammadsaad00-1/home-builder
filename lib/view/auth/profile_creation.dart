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
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
            padding: const EdgeInsets.only(left: 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height: h * 0.04),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: _image != null ? FileImage(_image!) : const AssetImage('assets/images/profile.jpg') as ImageProvider,
                    radius: 85,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: appColors.orangee,
                        radius: 25,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: h * 0.03),
            _buildTextField('Full name', nameController, Icons.perm_identity_sharp),
            _buildTextField('Email address', emailController, Icons.email_outlined),
            _buildPasswordField(),
            _buildTextField('Phone number', contactController, Icons.phone, keyboardType: TextInputType.number),
            SizedBox(height: h * 0.04),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () async {
                        final email = emailController.text.trim();
                        final name = nameController.text.trim();
                        final password = passController.text.trim();
                        final contact = contactController.text.trim();
                        await authViewModel.signup(email, password, name, contact, context);
                        Utils.flushBarErrorMessage('Account created successfully', context);
                      },
                      child: Container(
                        height: 60,
                        width: w * 0.9,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: appColors.orangee,
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
                          color: appColors.orangee,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(width: 4),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>  LoginViewUser()));
                      },
                      child: const Text("Login",
                          style: TextStyle(
                              color: appColors.orangee,
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(35)),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              prefixIcon: Icon(icon, color: Colors.black54, size: 35),
              border: InputBorder.none,
              hintText: label,
              hintStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 15),
            ),
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
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