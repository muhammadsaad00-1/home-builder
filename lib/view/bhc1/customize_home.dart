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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Request notification permission for Android 13+
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

    // Register notification channel for Android 8+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'project_channel_id', // Must match the ID used in NotificationDetails
      'Project Notifications',
      description: 'Notification when a new project is added',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showNotification() async {
    print("Showing notification..."); // Debugging

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

    print("Notification should be shown!"); // Debugging
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                SizedBox(height: h * 0.03),
                Text(
                  'Customize your home',
                  style: GoogleFonts.roboto(
                    color: appColors.orangee,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: h * 0.03),

                // WINDOWS
                buildSelectionTile(
                  title: 'Windows',
                  image: 'assets/images/home2.jpg',
                  nextScreenBuilder: () =>
                      Windows(selectedIndex: selectedWindowIndex),
                  onSelection: (value) =>
                      setState(() => selectedWindowIndex = value),
                ),

                // DOORS
                buildSelectionTile(
                  title: 'Doors',
                  image: 'assets/images/doors.jpg',
                  nextScreenBuilder: () =>
                      Doors(selectedIndex2: selectedDoorIndex),
                  onSelection: (value) =>
                      setState(() => selectedDoorIndex = value),
                ),

                // FLOORING
                buildSelectionTile(
                  title: 'Flooring',
                  image: 'assets/images/flooring.jpg',
                  nextScreenBuilder: () =>
                      Flooring(selectedIndex: selectedFlooringIndex),
                  onSelection: (value) =>
                      setState(() => selectedFlooringIndex = value),
                ),

                // KITCHEN
                buildSelectionTile(
                  title: 'Kitchen',
                  image: 'assets/images/kitchen.jpg',
                  nextScreenBuilder: () =>
                      Kitchen(selectedIndex: selectedKitchenIndex),
                  onSelection: (value) =>
                      setState(() => selectedKitchenIndex = value),
                ),

                // BATHROOM
                buildSelectionTile(
                  title: 'Bathroom',
                  image: 'assets/images/bathroom.jpg',
                  nextScreenBuilder: () =>
                      Bathroom(selectedIndex: selectedBathroomIndex),
                  onSelection: (value) =>
                      setState(() => selectedBathroomIndex = value),
                ),

                // LIGHTING
                buildSelectionTile(
                  title: 'Lighting',
                  image: 'assets/images/lightning.jpg',
                  nextScreenBuilder: () =>
                      Lighting(selectedIndex: selectedLightingIndex),
                  onSelection: (value) =>
                      setState(() => selectedLightingIndex = value),
                ),

                SizedBox(height: h * 0.02),

                // NEXT BUTTON (Navigates to HomeView and triggers notification)
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
                    backgroundColor: appColors.orangee,
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
    required Widget Function() nextScreenBuilder,
    required Function(int) onSelection,
  }) {
    return InkWell(
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
    );
  }
}
