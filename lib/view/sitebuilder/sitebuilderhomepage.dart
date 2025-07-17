import 'package:bhc/view/auth/initialpage.dart';
import 'package:bhc/view/sitebuilder/sitedetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../resources/components/appColors.dart';

class SiteBuilderHome extends StatefulWidget {
  const SiteBuilderHome({super.key});

  @override
  State<SiteBuilderHome> createState() => _SiteBuilderHomeState();
}

class _SiteBuilderHomeState extends State<SiteBuilderHome> {
  String? currentUserEmail;
  List<Map<String, dynamic>> filteredProjects = [];

  @override
  void initState() {
    super.initState();
    currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
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
    });
  }
  void _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InitialPage()), // 🔹 Redirect to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black87),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Image.asset('assets/images/logo.png'),
        ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red), // 🔹 Logout Icon
              onPressed: _signOut,
            ),
          ]
      ),
      body: filteredProjects.isEmpty
          ? const Center(child: Text('No projects assigned to you.'))
          : ListView.builder(
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          var project = filteredProjects[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                project['projectName'],
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
