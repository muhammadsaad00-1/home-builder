import 'package:bhc/view/bhc1/notifications.dart';
import 'package:bhc/view/bhc1/projectscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/components/appColors.dart';
import 'home_details.dart';
import '../auth/initialpage.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  // Dashboard related variables
  List<Map<String, String>> projects = [];
  bool _isLoading = true;
  String? _pressedProjectId;

  // Profile related variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects();
    _fetchUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// **Fetches projects ordered by `createdAt` in descending order**
  Future<void> fetchProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      QuerySnapshot projectSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        projects = projectSnapshot.docs
            .map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            "projectId": doc.id,
            "projectName": data['projectName'] as String? ?? 'Unnamed Project',
            "selectedFacadeImage": data['selectedFacadeImage'] as String? ?? '',
          };
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching projects: $e");
      setState(() => _isLoading = false);
    }
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
          contactController.text = userDoc.data().toString().contains('contact')
              ? userDoc['contact']
              : '03xx-xxxxxxxx';
          isProfileLoading = false;
        });
      }
    }
  }

  /// **Update Name & Phone Number in Firestore**
  Future<void> _updateUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'contact': contactController.text.isEmpty
            ? "03xx-xxxxxxxx"
            : contactController.text,
      }, SetOptions(merge: true));
      Fluttertoast.showToast(
        msg: "Profile updated",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  /// **Logout Functionality**
  Future<void> _logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InitialPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          title: Text(
            _selectedIndex == 0 ? 'Dashboard' : 'Profile',
            style: TextStyle(color: Colors.black87),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: w * 0.01),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, size: 30),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 30),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProjectSelection()));
          },
          backgroundColor: Colors.black87,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        )
            : null,
        body: SafeArea(
          child: _selectedIndex == 0 ? _buildDashboard(h, w) : _buildProfile(h, w),
        ),
      ),
    );
  }

  /// **Dashboard Content**
  Widget _buildDashboard(double h, double w) {
    return Padding(
      padding: const EdgeInsets.all(9.0),
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 20),
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
                : projects.isEmpty
                ? const Center(
              child: Text(
                "No Projects Were Found",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: fetchProjects,
                  child: ListView.builder(
                                padding: const EdgeInsets.all(10),
                                itemCount: projects.length,
                                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: buildProjectTile(
                      projects[index]["projectId"]!,
                      projects[index]["projectName"]!,
                      projects[index]["selectedFacadeImage"]!,
                    ),
                  );
                                },
                              ),
                ),
          ),
        ],
      ),
    );
  }

  /// **Profile Content**
  Widget _buildProfile(double h, double w) {
    return isProfileLoading
        ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black87,
        ))
        : SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.02),
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
              isEnabled: false,
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: _updateUserData,
                  child: SizedBox(
                    height: 55,
                    width: w * 0.9,
                    child: const Center(
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
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
                    color: Colors.black87,
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
    );
  }

  /// **Creates a project tile that navigates to HomeDetailsView with projectId**
  Widget buildProjectTile(String projectId, String projectName, String selectedFacadeImageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDetailsView(
              projectId: projectId,
              projectName: projectName,
            ),
          ),
        );
      },
      onTapDown: (_) {
        setState(() {
          _pressedProjectId = projectId;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressedProjectId = null;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressedProjectId = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: _pressedProjectId == projectId ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: selectedFacadeImageUrl.isNotEmpty
                      ? Image.network(
                    selectedFacadeImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to hardcoded asset image if network image fails
                      return Image.asset(
                        'assets/firstFloor/Barbie_Facade.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    },
                  )
                      : Image.asset(
                    'assets/firstFloor/Barbie_Facade.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  projectName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}