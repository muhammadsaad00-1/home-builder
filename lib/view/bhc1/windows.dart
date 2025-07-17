import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../resources/components/appColors.dart';

class Windows extends StatefulWidget {
  final int? selectedIndex;

  Windows({this.selectedIndex});

  @override
  _WindowsState createState() => _WindowsState();
}

class _WindowsState extends State<Windows> {
  List<String> imageUrls = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    fetchWindowImages();
  }

  /// **Fetch Window Image URLs from Firebase Storage**
  Future<void> fetchWindowImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("windows");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in Windows folder.");
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

  /// **Save Selected Window Image URL to Firestore**
  Future<void> _saveSelectedWindow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("No user logged in");
      return;
    }

    if (selectedIndex == null || imageUrls.isEmpty) {
      debugPrint("No window design selected.");
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
        String selectedImageUrl = imageUrls[selectedIndex!];

        await userDoc.collection('projects').doc(projectId).update({
          'selectedWindow': selectedImageUrl, // Save the selected image URL
          'updatedAt': FieldValue.serverTimestamp(),
        });

        debugPrint("Window selection saved: $selectedImageUrl");
      } else {
        debugPrint("No projects found for user.");
      }
    } catch (e) {
      debugPrint("Error saving window selection: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Select Windows Design',
          style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: imageUrls.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                    color: Colors.black87,
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      bool isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
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
                                  imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (selectedIndex != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSelectedWindow();
                  Navigator.pop(context, selectedIndex);
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
