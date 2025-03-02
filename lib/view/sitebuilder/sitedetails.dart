import 'package:bhc/resources/components/appColors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SiteDetails extends StatefulWidget {
  final String projectId;
  final String projectName;

  const SiteDetails({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  _SiteDetailsState createState() => _SiteDetailsState();
}

class _SiteDetailsState extends State<SiteDetails> {
  final ImagePicker _picker = ImagePicker();
  List<String?> images = List.filled(7, null); // Store URLs instead of Files
  List<String> labels = ['Bathroom', 'Flooring', 'Kitchen', 'Lighting', 'Doors', 'Window', 'Facade'];

  @override
  void initState() {
    super.initState();
    fetchExistingImages();
  }

  // 📌 Pick image from gallery
  Future<void> pickImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(imageFile, labels[index], index);
    }
  }

  // 📌 Upload image to Firebase Storage
  Future<void> uploadImage(File imageFile, String label, int index) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('projects/${widget.projectId}/$label.jpg');

      await storageRef.putFile(imageFile);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        images[index] = downloadUrl; // ✅ Store URL, not File
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  // 📌 Fetch existing images from Firebase Storage
  Future<void> fetchExistingImages() async {
    try {
      ListResult result = await FirebaseStorage.instance.ref('projects/${widget.projectId}').listAll();
      if (result.items.isNotEmpty) {
        for (var item in result.items) {
          String url = await item.getDownloadURL();
          int index = labels.indexOf(item.name.replaceAll('.jpg', ''));
          if (index != -1) {
            setState(() {
              images[index] = url; // ✅ Store URL instead of File
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Upload Images', style: TextStyle(
            fontWeight: FontWeight.w500,
            color: appColors.orangee
        )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 7,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => pickImage(index),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    width: double.infinity,
                    height: double.infinity,
                    child: images[index] != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        images[index]!, // ✅ Load from Firebase URL
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700]),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        labels[index],
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
