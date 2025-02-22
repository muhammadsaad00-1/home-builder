import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/floor_selection.dart';
import 'package:bhc/view/bhc2/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectSelection extends StatefulWidget {
  const ProjectSelection({super.key});

  @override
  State<ProjectSelection> createState() => _ProjectSelectionState();
}

class _ProjectSelectionState extends State<ProjectSelection> {
  final TextEditingController _projectNameController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Project"),
        backgroundColor: appColors.orangee,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text Field for Project Name Entry
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: "Enter Project Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: h * 0.02),

            // Enter Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleProjectCreation,
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.orangee,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Enter",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),

            SizedBox(height: h * 0.04),

            // Old Projects Button
          ],
        ),
      ),
    );
  }

  /// **Handles project creation when the "Enter" button is pressed**
  Future<void> _handleProjectCreation() async {
    String projectName = _projectNameController.text.trim();
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a project name")),
      );
      return;
    }

    setState(() => _isLoading = true); // Show loading indicator

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("No user logged in");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      CollectionReference projectsRef = userDoc.collection('projects');

      DocumentReference newProject = await projectsRef.add({
        'projectName': projectName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'selectedFloor': [],
      });

      debugPrint(
          "New project created with ID: ${newProject.id}, Name: $projectName");

      // Clear the text field after project creation
      _projectNameController.clear();

      // Navigate to FloorSelection after creating the project
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FloorSelection()),
      );
    } catch (e) {
      debugPrint("Error creating new project: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  /// **Navigates to a new screen**
  void _navigateTo(BuildContext context, Widget destination) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }
}
