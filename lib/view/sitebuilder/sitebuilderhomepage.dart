import 'package:bhc/view/auth/initialpage.dart';
import 'package:bhc/view/bhc1/notifications.dart';
import 'package:bhc/view/sitebuilder/sitedetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../resources/components/appColors.dart';

class SiteBuilderHome extends StatefulWidget {
  const SiteBuilderHome({super.key});

  @override
  State<SiteBuilderHome> createState() => _SiteBuilderHomeState();
}

class _SiteBuilderHomeState extends State<SiteBuilderHome> {
  int _currentIndex = 0;
  String? currentUserEmail;
  List<Map<String, dynamic>> filteredProjects = [];
  bool isLoadingProjects = true;

  // Profile related variables
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  bool isLoadingProfile = true;

  // Store original values to compare for changes
  String originalName = '';
  String originalContact = '';

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _fetchProjects();
    _fetchUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    super.dispose();
  }

  Future<void> _fetchProjects() async {
    try {
      setState(() {
        isLoadingProjects = true;
      });

      List<Map<String, dynamic>> projects = [];
      var usersSnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        var projectsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('projects')
            .get();

        for (var projectDoc in projectsSnapshot.docs) {
          var data = projectDoc.data();
          if (data['sitebuilder'] == currentUserEmail) {
            projects.add({
              'projectId': projectDoc.id,
              'projectName': data['projectName'],
            });
          }
        }
      }

      setState(() {
        filteredProjects = projects;
        isLoadingProjects = false;
      });
    } catch (e) {
      print('Error fetching projects: $e');
      setState(() {
        filteredProjects = [];
        isLoadingProjects = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            nameController.text = userData?['name'] ?? '';
            emailController.text = userData?['email'] ?? user.email ?? '';
            contactController.text = userData?['contact'] ?? '03xx-xxxxxxxx';
            // Store original values
            originalName = nameController.text;
            originalContact = contactController.text;
            isLoadingProfile = false;
          });
        } else {
          // Document doesn't exist, set default values
          setState(() {
            nameController.text = '';
            emailController.text = user.email ?? '';
            contactController.text = '03xx-xxxxxxxx';
            // Store original values
            originalName = nameController.text;
            originalContact = contactController.text;
            isLoadingProfile = false;
          });
        }
      } else {
        // No user logged in
        setState(() {
          originalName = '';
          originalContact = '03xx-xxxxxxxx';
          isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // In case of error, still stop loading
      setState(() {
        emailController.text = _auth.currentUser?.email ?? '';
        contactController.text = '03xx-xxxxxxxx';
        originalName = '';
        originalContact = '03xx-xxxxxxxx';
        isLoadingProfile = false;
      });
    }
  }

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
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InitialPage()),
    );
  }

  // Dashboard Screen Widget
  Widget _buildDashboardScreen() {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          title: Text(
            'Dashboard',
            style: TextStyle(color: Colors.black87),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Image.asset('assets/images/logo.png'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.grey),
              onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationsView()));},
            ),
          ]
      ),
      body: isLoadingProjects
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black87,
        ),
      )
          : filteredProjects.isEmpty
          ? const Center(child: Text('No projects assigned to you.'))
          : ListView.builder(
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          var project = filteredProjects[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.grey[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SiteDetails(
                          projectId: project['projectId'],
                          projectName: project['projectName'],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.web,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            project['projectName'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.6),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Profile Screen Widget
  Widget _buildProfileScreen() {
    final h = MediaQuery.sizeOf(context).height;
    final w = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black87),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
      body: SafeArea(
        child: isLoadingProfile
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
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: _signOut,
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
        ),
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: _currentIndex == 0 ? _buildDashboardScreen() : _buildProfileScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
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
      ),
    );
  }
}