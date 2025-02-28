import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/first.dart';
import 'package:bhc/view/bhc1/second.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FloorSelection extends StatelessWidget {
  const FloorSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Storey Plan",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: appColors.orangee),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFloorButton(context, "Single Storey", FirstScreen(), "1"),
            SizedBox(height: h * 0.02),
            _buildFloorButton(context, "Double Storey", SecondScreen(), "2"),
          ],
        ),
      ),
    );
  }

  /// **Builds a button for floor selection**
  Widget _buildFloorButton(BuildContext context, String floorName,
      Widget floorScreen, String floorValue) {
    return ElevatedButton(
      onPressed: () async {
        await _saveSelectedFloor(floorValue);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => floorScreen),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: appColors.orangee,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        floorName,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  /// **Saves the selected floor in Firestore under the latest project**
  Future<void> _saveSelectedFloor(String floorValue) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("No user logged in");
      return;
    }

    try {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      QuerySnapshot projectSnapshot = await userDoc
          .collection('projects')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (projectSnapshot.docs.isNotEmpty) {
        String projectId = projectSnapshot.docs.first.id;

        await userDoc.collection('projects').doc(projectId).update({
          'selectedFloor': floorValue, // Store floor type as a single value
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint("Floor selection saved: $floorValue");
      } else {
        debugPrint("No projects found for user.");
      }
    } catch (e) {
      debugPrint("Error saving floor selection: $e");
    }
  }
}
