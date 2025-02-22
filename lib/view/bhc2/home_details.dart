import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../resources/components/appColors.dart';

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
    'Bathroom', 'Door', 'Kitchen', 'Window', 'Lighting', 'Facade', 'Flooring', 'Floor Plan', 'Second Facade'
  ];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchProjectDetails();
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
              'selectedBathroom', 'selectedDoor', 'selectedKitchen',
              'selectedWindow', 'selectedLighting', 'selectedFacadeImage',
              'selectedFlooring', 'selectedFloorPlan', 'selectedSecondFacadeImage'
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
        builder: (context) => FullScreenImageView(imageUrls: imageUrls, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appColors.orangee,
        title: Text('Home Details',
            style: GoogleFonts.roboto(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError || projectData == null
          ? const Center(child: Text("No project data found"))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labels[index],
                      style: GoogleFonts.roboto(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => openFullScreenImage(index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrls[index],
                        width: w * 0.9,
                        height: h * 0.3,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<String> imageUrls;
  final int index;

  const FullScreenImageView({super.key, required this.imageUrls, required this.index});

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