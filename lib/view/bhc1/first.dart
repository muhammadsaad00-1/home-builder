import 'dart:typed_data';
import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/choose_floor_plan_firstfloor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  List<Reference> imageRefs = [];
  List<Map<String, String>> images = []; // List of { path, url }

  Map<String, Uint8List> imageData = {};
  String? selectedImage;
  String? selectedImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageReferences();
  }

  Future<void> fetchImageReferences() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("firstFloor");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in firstFloor folder.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        imageRefs = result.items;
      });

      await fetchImageDownloadURLs();
    } catch (e) {
      debugPrint("Error fetching images: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchImageDownloadURLs() async {
    try {
      final List<Future<void>> futures = imageRefs.map((ref) async {
        try {
          final url = await ref.getDownloadURL();
          images.add({
            'path': ref.fullPath,
            'url': url,
          });
        } catch (e) {
          debugPrint("Error getting download URL: $e");
        }
      }).toList();

      await Future.wait(futures);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching URLs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios_new,color: Colors.black,)),

        automaticallyImplyLeading: false,
        title: Text(
          'Select a Single Storey Facade',
          style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
              itemCount: images.length,
              itemBuilder: (context, index) {
                String imagePath = images[index]['path']!;
                String imageUrl = images[index]['url']!;
                bool isSelected = selectedImage == imagePath;
                String imageName = imagePath.split('/').last.split('.').first;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = imagePath;
                      selectedImageUrl = imageUrl;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            height: 200,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 200,
                                child: Center(child: Icon(Icons.error)),
                              );
                            },
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
                            imageName,
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
                  backgroundColor: Colors.black87,
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
