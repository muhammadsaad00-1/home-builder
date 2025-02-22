import 'package:flutter/material.dart';
import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/customize_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseFloorPlanFirst extends StatefulWidget {
  const ChooseFloorPlanFirst({super.key});

  @override
  _ChooseFloorPlanFirstState createState() => _ChooseFloorPlanFirstState();
}

class _ChooseFloorPlanFirstState extends State<ChooseFloorPlanFirst> {
  List<String> imageUrls = [];
  int selectedIndex = 0;

  final List<String> descriptions = [
    "This is description for Floor Plan 1",
    "This is description for Floor Plan 2",
    "This is description for Floor Plan 3",
  ];

  @override
  void initState() {
    super.initState();
    fetchFloorPlanImages();
  }

  /// **Fetch Floor Plan Image URLs from Firebase Storage**
  Future<void> fetchFloorPlanImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("firstfloorplans");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in the firstfloorplans folder.");
        return;
      }

      List<String> urls = await Future.wait(
        result.items.map((ref) async {
          return await ref.getDownloadURL();
        }),
      );

      setState(() {
        imageUrls = urls;
      });
    } catch (e) {
      debugPrint("Error fetching images: $e");
    }
  }

  /// **Save Selected Floor Plan URL to Firestore**
  Future<void> _saveSelectedFloorPlan() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("No user logged in");
      return;
    }

    if (imageUrls.isEmpty) {
      debugPrint("No floor plan images available.");
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
        String selectedImageUrl = imageUrls[selectedIndex];

        await userDoc.collection('projects').doc(projectId).update({
          'selectedFloorPlan': selectedImageUrl, // Save the selected image URL
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint("Floor plan saved: $selectedImageUrl");
      } else {
        debugPrint("No projects found for user.");
      }
    } catch (e) {
      debugPrint("Error saving floor plan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double h = MediaQuery.of(context).size.height;
    final double w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: h * 0.04),
              Text(
                'Choose Your Floor Plan',
                style: GoogleFonts.roboto(
                  color: appColors.orangee,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.02),
              SizedBox(
                height: h * 0.45,
                child: imageUrls.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageUrls.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.orange
                                      : Colors.transparent,
                                  width: selectedIndex == index ? 3 : 0,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                imageUrls[index],
                                height: h * 0.45,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: h * 0.02),
              Text(
                'Description',
                style: GoogleFonts.roboto(
                  color: appColors.greyy,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.02),
              Text(
                descriptions[selectedIndex % descriptions.length],
                style: GoogleFonts.roboto(
                  color: appColors.greyy,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              SizedBox(height: h * 0.06),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () async {
                    await _saveSelectedFloorPlan();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomizeHomeView(),
                      ),
                    );
                  },
                  child: Container(
                    height: 60,
                    width: w * 0.9,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appColors.orangee,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Text(
                        "Next",
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
            ],
          ),
        ),
      ),
    );
  }
}
