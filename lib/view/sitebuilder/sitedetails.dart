import 'package:bhc/resources/components/appColors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
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
  String? uploadedFileUrl;
  int fileIndex = 1;
  bool isIndexLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchFileIndex();
  }

  Future<void> fetchFileIndex() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        setState(() {
          isIndexLoaded = true;
        });
      }
      return;
    }

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('projects')
          .doc(widget.projectId)
          .get();

      if (mounted) {
        setState(() {
          if (snapshot.exists && snapshot['fileIndex'] != null) {
            fileIndex = snapshot['fileIndex'];
          }
          isIndexLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isIndexLoaded = true;
        });
      }
    }
  }

  Future<File?> compressImage(File imageFile) async {
    try {
      final directory = await getTemporaryDirectory();
      final String targetPath = '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 600,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
    } catch (e) {
      print('Error compressing image: $e');
    }

    return imageFile; // Return original if compression fails
  }

  bool isImageFile(String filePath) {
    final String extension = filePath.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'].contains(extension);
  }

  Future<void> pickMedia() async {
    // Wait for the file index to be loaded before proceeding
    if (!isIndexLoaded) {
      await fetchFileIndex();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File mediaFile = File(result.files.single.path!);

      // Compress image if it's an image file
      if (isImageFile(mediaFile.path)) {
        if (mounted) {

        }

        File? compressedFile = await compressImage(mediaFile);
        if (compressedFile != null) {
          mediaFile = compressedFile;
        }
      }

      String extension = mediaFile.path.split('.').last;
      String fileName = 'index$fileIndex.$extension';

      try {
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Uploading...",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey.shade800,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('projects/${widget.projectId}/$fileName');

        await storageRef.putFile(mediaFile);
        String downloadUrl = await storageRef.getDownloadURL();

        // Clean up compressed file if it was created
        if (isImageFile(result.files.single.path!) &&
            mediaFile.path != result.files.single.path!) {
          try {
            await mediaFile.delete();
          } catch (e) {
            print('Error deleting temporary compressed file: $e');
          }
        }

        // Check if widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            uploadedFileUrl = downloadUrl;
            fileIndex++;
          });

          // Show success toast notification
          Fluttertoast.showToast(
            msg: "File uploaded successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey.shade800,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }

        // Update the fileIndex in Firestore
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('projects')
              .doc(widget.projectId)
              .set({'fileIndex': fileIndex}, SetOptions(merge: true));
        }
      } catch (e) {
        print('Error uploading file: $e');
        if (mounted) {
          Fluttertoast.showToast(
            msg: "Upload failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red.shade800,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.projectName,
            style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.black87)),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: isIndexLoaded ? pickMedia : null, // Disable tap until index is loaded
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: isIndexLoaded ? Colors.grey[200] : Colors.grey[300],
            ),
            child: isIndexLoaded
                ? (uploadedFileUrl != null
                ? Icon(
              uploadedFileUrl!.contains('.mp4')
                  ? Icons.videocam
                  : Icons.camera,
              size: 60,
              color: Colors.grey[700],
            )
                : Icon(Icons.add_a_photo, size: 60, color: Colors.grey[700]))
                : CircularProgressIndicator(color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}