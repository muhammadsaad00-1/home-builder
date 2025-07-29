import 'package:bhc/view/auth/loginviewuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showPass = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Firebase signup method
  Future<void> _signupWithFirebase() async {
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final password = passController.text.trim();
    final contact = contactController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty || contact.isEmpty) {
      _showToast("Please fill in all fields", Colors.red);
      return;
    }

    if (!_isValidEmail(email)) {
      _showToast("Please enter a valid email address", Colors.red);
      return;
    }

    if (password.length < 6) {
      _showToast("Password must be at least 6 characters", Colors.red);
      return;
    }

    if (contact.length < 10) {
      _showToast("Please enter a valid phone number", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Create user with Firebase
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Update user profile with name
        await user.updateDisplayName(name);

        // Send email verification
        await user.sendEmailVerification();

        // Show success toast with gray background
        _showToast(
          "Verification link has been sent to your email",
          Colors.grey,
        );

        // Optional: You can store additional user data in Firestore here
        await _storeUserData(user.uid, name, email, contact);

        // Navigate back to login screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginViewUser()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          errorMessage = "An account already exists for that email.";
          break;
        case 'invalid-email':
          errorMessage = "The email address is badly formatted.";
          break;
        case 'operation-not-allowed':
          errorMessage = "Email/password accounts are not enabled.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = "An error occurred during registration. Please try again.";
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
  Future<void> _storeUserData(String uid, String name, String email, String contact) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'contact': contact,
        'createdAt': FieldValue.serverTimestamp(),
        // Add any other fields you want
      });
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  // Custom toast method
  void _showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // Email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Optional: Store additional user data in Firestore
  // Future<void> _storeUserData(String uid, String name, String email, String contact) async {
  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //       'name': name,
  //       'email': email,
  //       'contact': contact,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     print('Error storing user data: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w*0.06),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.1),
                  Center(
                    child: Image.asset('assets/images/logo.png', height: w*0.2),
                  ),
                  SizedBox(height: h * 0.1),
                  _buildTextField(
                      false, 'Full name', nameController, 20, Icons.perm_identity_sharp),
                  _buildTextField(
                      false,'Email address', emailController, 35, Icons.email_outlined),
                  _buildTextField(true, "Password", passController, 12, Icons.import_contacts_sharp),
                  _buildTextField(false,'Phone number', contactController, 13, Icons.phone,
                    keyboardType: TextInputType.number,),
                  SizedBox(height: h * 0.04),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: isLoading ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          await _signupWithFirebase();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: w * 0.9,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: isLoading ? Colors.grey : Colors.black87,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                              : const Text(
                            "Continue",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h * 0.02),

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
      ),
    );
  }

  Widget _buildTextField(
      bool isPassword, String label, TextEditingController controller, int maxchar, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
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
            child: TextFormField(
              controller: controller,
              maxLength: maxchar,
              keyboardType: keyboardType,
              cursorColor: Colors.black,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your $label';
                }
                if (label == 'Email address' && !_isValidEmail(value)) {
                  return 'Please enter a valid email address';
                }
                if (label == 'Phone number' && value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              decoration: InputDecoration(
                counterText: '',
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
            child: TextFormField(
              controller: controller,
              obscureText: showPass,
              keyboardType: keyboardType,
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
                suffixIcon: IconButton(onPressed: (){
                  setState(() {
                    showPass = !showPass;
                  });
                }, icon: showPass ? Icon(Icons.visibility_off) : Icon(Icons.visibility)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    passController.dispose();
    super.dispose();
  }
}