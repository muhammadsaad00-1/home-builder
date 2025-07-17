import 'package:bhc/resources/components/appColors.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class HomeDetailUpdates extends StatefulWidget {
  final String projectId;
  final String projectName;

  const HomeDetailUpdates(
      {super.key, required this.projectId, required this.projectName});

  @override
  _HomeDetailUpdatesState createState() => _HomeDetailUpdatesState();
}

class _HomeDetailUpdatesState extends State<HomeDetailUpdates> {
  List<Map<String, dynamic>> mediaFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMediaFiles();
  }

  Future<void> fetchMediaFiles() async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref("projects/${widget.projectId}");
      final ListResult result = await storageRef.listAll();

      if (result.items.isEmpty) {
        debugPrint("No media found in project folder: ${widget.projectId}.");
        setState(() => isLoading = false);
        return;
      }

      List<Map<String, dynamic>> tempFiles = [];

      for (var item in result.items) {
        String url = await item.getDownloadURL();
        bool isVideo = url.contains(".mp4");
        tempFiles.add({"url": url, "isVideo": isVideo});
      }

      setState(() {
        mediaFiles = tempFiles;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching media: $e");
      setState(() => isLoading = false);
    }
  }

  void openFullScreenMedia(int index) {
    if (mediaFiles[index]["isVideo"]) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FullScreenVideoPlayer(videoUrl: mediaFiles[index]["url"]),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageView(
              images: mediaFiles.map((m) => m["url"] as String).toList(),
              index: index),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Project Media - ${widget.projectName}',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.white,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: mediaFiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => openFullScreenMedia(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: mediaFiles[index]["isVideo"]
                        ? VideoPlayerWidget(videoUrl: mediaFiles[index]["url"])
                        : Image.network(mediaFiles[index]["url"],
                            fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isDisposed = false; // To prevent setting state after dispose

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (!_isDisposed) setState(() {});
      });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class FullScreenImageView extends StatelessWidget {
  final List<String> images;
  final int index;

  const FullScreenImageView(
      {super.key, required this.images, required this.index});

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
                imageProvider: NetworkImage(images[i]),
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

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FullScreenVideoPlayer({super.key, required this.videoUrl});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        if (!_isDisposed) {
          setState(() {});
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.pause(); // Stop playback before disposing
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
