import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import '../../resources/components/appColors.dart';
import 'package:photo_view/photo_view.dart';
import 'home.dart';
import 'home_details_update.dart';

class HomeDetailsView extends StatefulWidget {
  final String projectId;
  final String projectName;

  const HomeDetailsView({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<HomeDetailsView> createState() => _HomeDetailsViewState();
}

class _HomeDetailsViewState extends State<HomeDetailsView> {
  Map<String, dynamic>? projectData;
  List<String> imageUrls = [];
  List<String> labels = [
    'Bathroom',
    'Door',
    'Kitchen',
    'Window',
    'Lighting',
    'Facade',
    'Flooring',
    'Floor Plan',
  ];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
  }

  Future<void> deleteProject() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(widget.projectId)
          .delete();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } catch (e) {
      print("Error deleting project: $e");
    }
  }

  Future<void> fetchProjectDetails() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot projectDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(widget.projectId)
          .get();

      if (projectDoc.exists) {
        Map<String, dynamic> data = projectDoc.data() as Map<String, dynamic>;
        if (data['projectName'] == widget.projectName) {
          setState(() {
            projectData = data;
            List<String> fields = [
              'selectedBathroom',
              'selectedDoor',
              'selectedKitchen',
              'selectedWindow',
              'selectedLighting',
              'selectedFacadeImage',
              'selectedFlooring',
              'selectedFloorPlan',
            ];
            imageUrls = fields
                .map((field) => data[field])
                .where((url) => url != null && url.toString().isNotEmpty)
                .cast<String>()
                .toList();
          });
        } else {
          setState(() => hasError = true);
        }
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void openFullScreenImage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageView(imageUrls: imageUrls, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Home Details',
            style: GoogleFonts.roboto(
              color: Colors.black87,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 24),
            onPressed: deleteProject,
          ),
        ],
      ),
      body: isLoading
          ? ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: h * 0.3,
            width: w * 0.95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      )
          : hasError || projectData == null
          ? const Center(child: Text("No project data found"))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, right: 10, bottom: 10, top: 20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(labels[index],
                              style: GoogleFonts.roboto(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => openFullScreenImage(index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              imageUrls[index],
                              width: w * 0.95,
                              height: labels[index] == "Floor Plan"
                                  ? h * 0.25
                                  : h * 0.3,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeDetailUpdates(
                        projectId: widget.projectId,
                        projectName: widget.projectName,
                      ),
                    ),
                  );
                },
                child: Text("Updates"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<String> imageUrls;
  final int index;

  const FullScreenImageView(
      {super.key, required this.imageUrls, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            pageController: PageController(initialPage: index),
            builder: (context, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[i]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
