import 'package:flutter/material.dart';
import 'package:bhc/resources/components/appColors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'customize_home.dart';

class ChooseFloorPlanSecond extends StatefulWidget {
  const ChooseFloorPlanSecond({super.key});

  @override
  _ChooseFloorPlanSecondState createState() => _ChooseFloorPlanSecondState();
}

class _ChooseFloorPlanSecondState extends State<ChooseFloorPlanSecond> {
  List<Uint8List?> imageDataList = [];
  int selectedIndex = 0;

  final List<String> descriptions = [
    "This is description for Floor Plan 1",
    "This is description for Floor Plan 2",
    "This is description for Floor Plan 3",
  ];

  @override
  void initState() {
    super.initState();
    fetchFloorMapImages();
  }

  Future<void> fetchFloorMapImages() async {
    try {
      final storageRef = FirebaseStorage.instanceFor(
        bucket: "gs://brighthomes-d1947.firebasestorage.app",
      ).ref("secondfloorplans");

      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in the secondfloorplans folder.");
        return;
      }

      List<Uint8List?> images = await Future.wait(
        result.items.map((ref) async {
          try {
            return await ref.getData(); // Fetches image data directly
          } catch (e) {
            debugPrint("Error fetching image data: \$e");
            return null;
          }
        }),
      );

      setState(() {
        imageDataList = images;
      });
    } catch (e) {
      debugPrint("Error fetching images: \$e");
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
                child: imageDataList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageDataList.length,
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
                              child: imageDataList[index] != null
                                  ? Image.memory(
                                      imageDataList[index]!,
                                      height: h * 0.45,
                                    )
                                  : const Icon(Icons.error),
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
                  onTap: () {
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
