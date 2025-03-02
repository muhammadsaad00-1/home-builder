import 'dart:typed_data';
import 'package:bhc/resources/components/appColors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class HomeDetailUpdates extends StatefulWidget {
  final String projectId;
  final String projectName;

  const HomeDetailUpdates({super.key, required this.projectId, required this.projectName});

  @override
  _HomeDetailUpdatesState createState() => _HomeDetailUpdatesState();
}

class _HomeDetailUpdatesState extends State<HomeDetailUpdates> {
  List<Reference> imageRefs = [];
  Map<String, Uint8List> imageData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImageReferences();
  }

  Future<void> fetchImageReferences() async {
    try {
      final storageRef = FirebaseStorage.instance.ref("projects/${widget.projectId}");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No images found in project folder: ${widget.projectId}.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      setState(() {
        imageRefs = result.items;
      });

      await fetchImagesParallel();
    } catch (e) {
      debugPrint("Error fetching images: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchImagesParallel() async {
    final List<Future<void>> futures = imageRefs.map((ref) async {
      try {
        Uint8List? data = await ref.getData(1024 * 500);
        if (data != null && mounted) {
          setState(() {
            imageData[ref.fullPath] = data;
          });
        }
      } catch (e) {
        debugPrint("Error loading image ${ref.fullPath}: $e");
      }
    }).toList();

    await Future.wait(futures);
    setState(() {
      isLoading = false;
    });
  }

  void openFullScreenImage(int index) {
    List<Uint8List> images = imageRefs.map((ref) => imageData[ref.fullPath]!).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(images: images, index: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'Project Images - ${widget.projectName}',
          style: GoogleFonts.roboto(
              color: appColors.orangee,
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
              itemCount: imageRefs.length,
              itemBuilder: (context, index) {
                String imagePath = imageRefs[index].fullPath;
                String imageName = imagePath.split('/').last.split('.').first;

                return GestureDetector(
                  onTap: () => openFullScreenImage(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
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
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<Uint8List> images;
  final int index;

  const FullScreenImageView({super.key, required this.images, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: index),
            builder: (context, i) {
              return PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(images[i]),
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