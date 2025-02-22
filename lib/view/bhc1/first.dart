import 'dart:typed_data';
import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/choose_floor_plan_firstfloor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final String bucketPath = "gs://brighthomes-d1947.firebasestorage.app";
  List<Reference> imageRefs = [];
  Map<String, Uint8List> imageData = {};
  String? selectedImage;
  String? selectedImageUrl;

  @override
  void initState() {
    super.initState();
    fetchImageReferences();
  }

  /// Fetch metadata (references) first
  Future<void> fetchImageReferences() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("firstFloor");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in firstFloor folder.");
        return;
      }

      setState(() {
        imageRefs = result.items;
      });

      // Fetch images asynchronously in parallel
      await fetchImagesParallel();
    } catch (e) {
      debugPrint("Error fetching images: $e");
    }
  }

  /// Fetch images concurrently with size limit (parallel fetching)
  Future<void> fetchImagesParallel() async {
    final List<Future<void>> futures = imageRefs.map((ref) async {
      try {
        Uint8List? data = await ref.getData(1024 * 500); // Limit to 500KB
        if (data != null && mounted) {
          setState(() {
            imageData[ref.fullPath] = data;
          });
        }
      } catch (e) {
        debugPrint("Error loading image ${ref.fullPath}: $e");
      }
    }).toList();

    await Future.wait(futures); // Wait for all images to load
  }

  /// Save selected facade image URL in Firestore
  Future<void> saveSelectedFacade() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
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

        // Update the latest project with the selected facade image
        await userDoc.collection('projects').doc(projectId).update({
          'selectedFacadeImage': selectedImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print("Facade image saved: $selectedImageUrl");
      } else {
        print("No projects found for user.");
      }
    } catch (e) {
      print("Error saving facade image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select a Single Storey Facade',
          style: GoogleFonts.roboto(color: appColors.orangee, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: imageRefs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: imageRefs.length,
                    itemBuilder: (context, index) {
                      String imagePath = imageRefs[index].fullPath;
                      bool isSelected = selectedImage == imagePath;

                      return GestureDetector(
                        onTap: () async {
                          String downloadUrl =
                              await imageRefs[index].getDownloadURL();

                          setState(() {
                            selectedImage = imagePath;
                            selectedImageUrl = downloadUrl;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? Colors.orange : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: imageData.containsKey(imagePath)
                                    ? Image.memory(
                                        imageData[imagePath]!,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  imagePath.split('/').last, // Display filename
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: () async {
                  await saveSelectedFacade();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChooseFloorPlanFirst()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.orangee,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
