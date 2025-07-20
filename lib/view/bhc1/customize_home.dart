import 'package:bhc/resources/components/customize_home_widget.dart';
import 'package:bhc/view/bhc1/doors.dart';
import 'package:bhc/view/bhc1/flooring.dart';
import 'package:bhc/view/bhc1/kitchen.dart';
import 'package:bhc/view/bhc1/lighting.dart';
import 'package:bhc/view/bhc1/windows.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

import '../../resources/components/appColors.dart';
import '../bhc2/home.dart';
import 'Bathroom.dart';

class CustomizeHomeView extends StatefulWidget {
  const CustomizeHomeView({super.key});

  @override
  State<CustomizeHomeView> createState() => _CustomizeHomeViewState();
}

class _CustomizeHomeViewState extends State<CustomizeHomeView> {
  int? selectedWindowIndex;
  int? selectedDoorIndex;
  int? selectedFlooringIndex;
  int? selectedLightingIndex;
  int? selectedKitchenIndex;
  int? selectedBathroomIndex;
  bool isLoading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadImages();
  }

  Future<void> _initializeNotifications() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload == 'navigate_to_home') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      }
    });

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'project_channel_id',
      'Project Notifications',
      description: 'Notification when a new project is added',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _loadImages() async {
    setState(() => isLoading = true);
    // Load images from Firebase or any other source here
    setState(() => isLoading = false);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'project_channel_id',
      'Project Notifications',
      channelDescription: 'Notification when a new project is added',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Project Added',
      'Tap to view your project',
      platformChannelSpecifics,
      payload: 'navigate_to_home',
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: h * 0.03),
                Row(
                  children: [
                    IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios_new,color: Colors.black,))
                    ,
                    SizedBox(width: MediaQuery.of(context).size.width*0.1,)
                    ,Text(
                      'Customize your home',
                      style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.03),
                isLoading
                    ? Column(
                        children: List.generate(
                          6,
                          (index) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              height: 100,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : buildSelectionTile(
                        title: 'Windows',
                        image: 'assets/images/home.png',
                        selectedIndex: selectedWindowIndex,
                        nextScreenBuilder: () =>
                            Windows(selectedIndex: selectedWindowIndex),
                        onSelection: (value) =>
                            setState(() => selectedWindowIndex = value),
                      ),
                buildSelectionTile(
                  title: 'Doors',
                  image: 'assets/images/door.png',
                  selectedIndex: selectedDoorIndex,
                  nextScreenBuilder: () =>
                      Doors(selectedIndex2: selectedDoorIndex),
                  onSelection: (value) =>
                      setState(() => selectedDoorIndex = value),
                ),
                buildSelectionTile(
                  title: 'Flooring',
                  image: 'assets/images/floor.png',
                  selectedIndex: selectedFlooringIndex,
                  nextScreenBuilder: () =>
                      Flooring(selectedIndex: selectedFlooringIndex),
                  onSelection: (value) =>
                      setState(() => selectedFlooringIndex = value),
                ),
                buildSelectionTile(
                  title: 'Kitchen',
                  image: 'assets/images/kitchen.png',
                  selectedIndex: selectedKitchenIndex,
                  nextScreenBuilder: () =>
                      Kitchen(selectedIndex: selectedKitchenIndex),
                  onSelection: (value) =>
                      setState(() => selectedKitchenIndex = value),
                ),
                buildSelectionTile(
                  title: 'Bathroom',
                  image: 'assets/images/bathroom.jpg',
                  selectedIndex: selectedBathroomIndex,
                  nextScreenBuilder: () =>
                      Bathroom(selectedIndex: selectedBathroomIndex),
                  onSelection: (value) =>
                      setState(() => selectedBathroomIndex = value),
                ),
                buildSelectionTile(
                  title: 'Lighting',
                  image: 'assets/images/lightning.png',
                  selectedIndex: selectedLightingIndex,
                  nextScreenBuilder: () =>
                      Lighting(selectedIndex: selectedLightingIndex),
                  onSelection: (value) =>
                      setState(() => selectedLightingIndex = value),
                ),
                SizedBox(height: h * 0.02),
                ElevatedButton(
                  onPressed: () {
                    _showNotification();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeView(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: h * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSelectionTile({
    required String title,
    required String image,
    required int? selectedIndex,
    required Widget Function() nextScreenBuilder,
    required Function(int) onSelection,
  }) {
    return Opacity(
      opacity: selectedIndex != null ? 0.6 : 1.0,
      child: InkWell(
        onTap: () async {
          final selectedIndex = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextScreenBuilder()),
          );

          if (selectedIndex != null) {
            onSelection(selectedIndex);
          }
        },
        child: HomeWidget(image: image, title: title),
      ),
    );
  }
}
