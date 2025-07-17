import 'package:flutter/material.dart';
import 'package:bhc/resources/components/appColors.dart';
import 'package:bhc/view/bhc1/customize_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class ChooseFloorPlanSecond extends StatefulWidget {
  const ChooseFloorPlanSecond({super.key});

  @override
  _ChooseFloorPlanSecondState createState() => _ChooseFloorPlanSecondState();
}

class _ChooseFloorPlanSecondState extends State<ChooseFloorPlanSecond> {
  List<String> imageUrls = [];
  int selectedIndex = 0;
  bool isLoading = true;

  final List<String> descriptions = [
    "5-bed, 3-bath home with a 2-car garage. Measures 11.30m wide for a 12.50m lot, extending 22.23m in length with a total area of 42.32sq, offering a spacious and luxurious layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 8.42m wide for a 10.20m lot, extending 15.42m in length with a total area of 22.22sq, offering a compact and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 15.09m wide for a 15.24m lot, extending 18.98m in length with a total area of 45.74sq, offering a spacious and well-designed layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 8.40m wide for a 10.00m lot, extending 19.54m in length with a total area of 21.53sq, offering a compact and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.63m wide for a 13.50m lot, extending 13.60m in length with a total area of 27.18sq, offering a spacious and functional layout.",
    "5-bed, 3-bath home with a 2-car garage. Measures 14.80m wide for a 16.65m lot, extending 25.00m in length with a total area of 56.25sq, offering a spacious and luxurious layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 9.00m wide for a 10.00m lot, extending 18.04m in length with a total area of 23.53sq, offering a practical and efficient layout.",
    "6-bed, 5-bath home with a 4-car garage. Measures 19.00m wide, offering a total area of 72.54sq, providing a luxurious and spacious layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.36m wide for a 12.56m lot, extending 25.68m in length with a total area of 35.60sq, offering a spacious and well-balanced layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 10.88m wide for a 12.50m lot, extending 16.48m in length with a total area of 24.87sq, offering a spacious and functional layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 11.96m wide for a 13.11m lot, extending 21.35m in length with a total area of 29.21sq, offering a spacious and well-designed layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 13.04m wide for a 15.00m lot, extending 13.98m in length with a total area of 28.43sq, offering a spacious and well-balanced layout."
  ];

  @override
  void initState() {
    super.initState();
    fetchFloorPlanImages();
  }

  Future<void> fetchFloorPlanImages() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("secondfloorplans");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in the secondfloorplans folder.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      List<String> urls = await Future.wait(
        result.items.map((ref) async {
          return await ref.getDownloadURL();
        }),
      );

      setState(() {
        imageUrls = urls;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching images: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
          'selectedFloorPlan': selectedImageUrl,
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
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: h * 0.02),
              SizedBox(
                height: h * 0.45,
                child: imageUrls.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.black87,
                      ))
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
                                      ? Colors.black87
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
                      color: Colors.black87,
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
