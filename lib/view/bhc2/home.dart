import 'package:bhc/view/bhc1/notifications.dart';
import 'package:bhc/view/bhc1/projectscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator.pop()
import 'package:shimmer/shimmer.dart';

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
  String? _pressedProjectId;

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
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 2,
          automaticallyImplyLeading: false,
          title: Text(
            'Home',
            style: TextStyle(color: appColors.orangee),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
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
                // Conditional UI Based on Project State
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
                          : ListView.builder(
                              padding: const EdgeInsets.all(10),
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: buildProjectTile(
                                    projects[index]["projectId"]!,
                                    projects[index]["projectName"]!,
                                  ),
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
              color: Colors.black.withOpacity(0.2),
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
                  child: Image.asset(
                    'assets/firstFloor/Barbie_Facade.png',
                    fit: BoxFit.fitHeight,
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
}
