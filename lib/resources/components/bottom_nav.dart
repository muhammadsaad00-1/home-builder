import 'package:bhc/view/bhc1/profile.dart';
import 'package:bhc/view/bhc1/projectscreen.dart';
import 'package:flutter/material.dart';

import '../../view/bhc2/home.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.orange, // Replace with your app's colors
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == currentIndex) return; // Prevent unnecessary reloads

        Widget nextScreen;
        switch (index) {
          case 0:
            nextScreen = const HomeView();
            break;

          case 1:
            nextScreen = const ProfileView();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );

        onTap(index); // Update state in the parent widget
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard, size: 30),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 30),
          label: 'Profile',
        ),
      ],
    );
  }
}
