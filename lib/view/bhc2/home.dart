import 'package:bhc/view/bhc1/notifications.dart';
import 'package:bhc/view/bhc1/projectscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator.pop()

import '../../resources/components/appColors.dart';
import '../../resources/components/bottom_nav.dart';
import 'home_details.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  List<Map<String, String>> projects = [];
  bool _isLoading = true; // Tracks loading state

  @override
  void initState() {
    super.initState();
    fetchProjects();
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
            .map((doc) => {
                  "projectId": doc.id,
                  "projectName": doc['projectName'] as String,
                })
            .toList();
        _isLoading = false; // Fetch complete
      });
    } catch (e) {
      print("Error fetching projects: $e");
      setState(() => _isLoading = false); // Stop loading in case of error
    }
  }

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
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProjectSelection()));
          },
          backgroundColor: appColors.orangee,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              children: [
                SizedBox(height: h * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Home',
                      style: GoogleFonts.roboto(
                          color: appColors.orangee,
                          fontSize: 22,
                          fontWeight: FontWeight.w500),
                    ),


                  ],
                ),
                SizedBox(height: h * 0.02),

                // Conditional UI Based on Project State
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
                          : ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                return buildProjectTile(
                                  projects[index]["projectId"]!,
                                  projects[index]["projectName"]!,
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Creates a project tile that navigates to HomeDetailsView with projectId**
  Widget buildProjectTile(String projectId, String projectName) {
    return InkWell(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: appColors.orangee,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            projectName,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
