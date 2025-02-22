import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/components/appColors.dart';
import '../auth/initialpage.dart';
import '../bhc2/home.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// **Fetch User Data from Firestore**
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          contactController.text = userDoc['contact'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  /// **Update Name & Phone Number in Firestore**
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'name': nameController.text,
        'contact': contactController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  /// **Logout Functionality**
  Future<void> _logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();

    // Navigate to InitialPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InitialPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: h * 0.02),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const HomeView()),
                          );
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: appColors.orangee,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: w * 0.3),
                      Text(
                        'Profile',
                        style: GoogleFonts.roboto(
                          color: appColors.orangee,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.01),
                  _buildProfileField(
                    label: 'Full name',
                    controller: nameController,
                    icon: Icons.perm_identity_sharp,
                    hint: "Enter your name",
                  ),
                  SizedBox(height: h * 0.02),
                  _buildProfileField(
                    label: 'Email address',
                    controller: emailController,
                    icon: Icons.email_outlined,
                    hint: "Enter your email",
                    isEnabled: false, // Email shouldn't be editable
                  ),
                  SizedBox(height: h * 0.02),
                  _buildProfileField(
                    label: 'Phone number',
                    controller: contactController,
                    icon: Icons.phone,
                    hint: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: h * 0.04),

                  /// **Update Button**
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _updateUserData,
                      child: Container(
                        height: 55,
                        width: w * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Update Profile",
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

                  /// **Logout Button**
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: _logoutUser,
                      child: Container(
                        height: 55,
                        width: w * 0.9,
                        decoration: BoxDecoration(
                          color: appColors.orangee,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Log out",
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
                  SizedBox(height: h * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// **Reusable Profile Field Widget**
Widget _buildProfileField({
  required String label,
  required TextEditingController controller,
  required IconData icon,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool isEnabled = true,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        enabled: isEnabled,
        cursorColor: Colors.black,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          prefixIcon: Icon(icon, color: Colors.black54, size: 28),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
        ),
        style: GoogleFonts.poppins(fontSize: 14),
      ),
    ],
  );
}
