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
    "4-bed, 2-bath home with a 2-car garage. Compact 11.03m width fits a 12.50m lot. Spanning 21.95m in length with a total area of 22.08sq, offering a balanced layout for modern living.",
    "3-bed, 2-bath home with a 1-car garage. Compact 7.85m width fits a 9.00m lot. Spanning 20.27m in length with a total area of 15.00sq, ideal for efficient and comfortable living.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.30m wide to fit a 12.50m lot, extending 22.20m in length with a total area of 23.35sq, offering a spacious and functional design.",
    "3-bed, 2-bath home with a 2-car garage. Measures 9.50m wide for a 10.65m lot, extending 21.17m in length with a total area of 19.06sq, ensuring a practical and comfortable layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.00m wide for a 13.20m lot, extending 22.67m in length with a total area of 26.68sq, offering a spacious and well-balanced design.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.45m wide for a 12.65m lot, extending 21.13m in length with a total area of 22.71sq, providing a spacious and functional layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.03m wide for a 12.50m lot, extending 20.27m in length with a total area of 20.44sq, offering a practical and comfortable design.",
    "3-bed, 2-bath home with a 1-car garage. Measures 8.80m wide for a 10.00m lot, extending 21.01m in length with a total area of 17.16sq, ensuring a smart and efficient layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 10.50m wide for a 10.50m lot, extending 20.39m in length with a total area of 18.32sq, offering a well-balanced and functional design.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.80m wide for a 14.00m lot, extending 21.37m in length with a total area of 25.30sq, offering a spacious and well-designed layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 12.80m wide for a 14.00m lot, extending 21.37m in length with a total area of 25.31sq, offering a spacious and functional layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.35m wide for a 12.50m lot, extending 22.40m in length with a total area of 24.34sq, offering a spacious and practical layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 11.28m wide for a 12.50m lot, extending 23.48m in length with a total area of 23.00sq, offering a spacious and efficient layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 10.07m wide for an 11.27m lot, extending 19.91m in length with a total area of 18.68sq, ensuring a functional and comfortable design.",
    "4-bed, 2-bath home with a 2-car garage. Measures 15.74m wide for a 17.00m lot, extending 24.51m in length with a total area of 36.87sq, offering a spacious and luxurious layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 15.64m wide for a 16.80m lot, extending 18.43m in length with a total area of 26.00sq, offering a spacious and functional layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 10.50m wide for a 10.50m lot, extending 21.85m in length with a total area of 20.55sq, offering a well-balanced and functional design.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.50m wide for a 14.00m lot, extending 21.73m in length with a total area of 26.62sq, offering a spacious and well-designed layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.70m wide for a 13.90m lot, extending 21.90m in length with a total area of 23.94sq, offering a spacious and functional design.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.45m wide for a 12.50m lot, extending 23.80m in length with a total area of 25.83sq, offering a spacious and practical layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 14.60m wide for a 15.80m lot, extending 24.825m in length with a total area of 34.10sq, offering a spacious and well-designed layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.15m wide for a 12.50m lot, extending 19.43m in length with a total area of 20.45sq, offering a practical and efficient layout.",
    "3-bed, 2-bath home with a 1-car garage. Measures 8.50m wide for an 8.50m lot, extending 15.90m in length with a total area of 13.33sq, offering a compact and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.91m wide for a 13.11m lot, extending 21.17m in length with a total area of 24.31sq, offering a spacious and functional layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 10.50m wide for an 11.65m lot, extending 21.59m in length with a total area of 19.80sq, offering a practical and comfortable layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 12.35m wide for a 13.50m lot, extending 19.07m in length with a total area of 21.93sq, offering a spacious and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 14.75m wide for a 16.00m lot, extending 21.94m in length with a total area of 29.81sq, offering a spacious and well-designed layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 12.50m wide for a 13.70m lot, extending 19.59m in length with a total area of 23.62sq, offering a spacious and functional layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.35m wide for a 12.55m lot, extending 23.68m in length with a total area of 25.73sq, offering a spacious and practical layout.",
    "3-bed, 2-bath home with a 1-car garage. Measures 9.50m wide for a 10.65m lot, extending 21.70m in length with a total area of 20.00sq, offering a functional and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.30m wide for a 12.50m lot, extending 23.19m in length with a total area of 24.94sq, offering a spacious and well-balanced layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.80m wide for a 14.00m lot, extending 20.38m in length with a total area of 25.20sq, offering a spacious and functional layout.",
    "3-bed, 2-bath home with a 1-car garage. Measures 8.50m wide for an 8.50m lot, extending 21.17m in length with a total area of 15.17sq, offering a compact and efficient layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 11.96m wide for a 13.16m lot, extending 24.15m in length with a total area of 26.60sq, offering a spacious and well-designed layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 11.35m wide for a 12.50m lot, extending 18.20m in length with a total area of 19.34sq, offering a practical and efficient layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 11.30m wide for a 12.50m lot, extending 21.10m in length with a total area of 22.20sq, offering a spacious and functional layout.",
    "4-bed, 3-bath home with a 2-car garage. Measures 14.41m wide for a 15.60m lot, extending 25.30m in length with a total area of 29.50sq, offering a spacious and well-designed layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 12.77m wide for a 13.97m lot, extending 20.97m in length with a total area of 25.36sq, offering a spacious and functional layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 14.51m wide for a 15.66m lot, extending 23.51m in length with a total area of 28.62sq, offering a spacious and well-designed layout.",
    "4-bed, 2-bath home with a 2-car garage. Measures 10.50m wide for a 10.50m lot, extending 21.47m in length with a total area of 20.31sq, offering a practical and efficient layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 10.50m wide for an 11.70m lot, extending 18.24m in length with a total area of 17.18sq, offering a compact and functional layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 11.60m wide for a 12.80m lot, extending 23.41m in length with a total area of 25.32sq, offering a spacious and well-designed layout.",
    "3-bed, 2-bath home with a 2-car garage. Measures 8.39m wide for a 10.00m lot, extending 21.23m in length with a total area of 16.57sq, offering a compact and efficient layout."
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
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
