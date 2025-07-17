import 'package:bhc/resources/components/appColors.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    fetchFileIndex();
  }

  Future<void> fetchFileIndex() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('projects')
        .doc(widget.projectId)
        .get();

    if (snapshot.exists && snapshot['fileIndex'] != null) {
      setState(() {
        fileIndex = snapshot['fileIndex'];
      });
    }
  }

  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      File mediaFile = File(result.files.single.path!);
      String extension = mediaFile.path.split('.').last;
      String fileName = 'index$fileIndex.$extension';

      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('projects/${widget.projectId}/$fileName');

      await storageRef.putFile(mediaFile);
      String downloadUrl = await storageRef.getDownloadURL();

      setState(() {
        uploadedFileUrl = downloadUrl;
        fileIndex++;
      });

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('projects')
            .doc(widget.projectId)
            .set({'fileIndex': fileIndex}, SetOptions(merge: true));
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
          onTap: pickMedia,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: uploadedFileUrl != null
                ? Icon(
                    uploadedFileUrl!.contains('.mp4')
                        ? Icons.videocam
                        : Icons.camera,
                    size: 60,
                    color: Colors.grey[700],
                  )
                : Icon(Icons.add_a_photo, size: 60, color: Colors.grey[700]),
          ),
        ),
      ),
    );
  }
}
