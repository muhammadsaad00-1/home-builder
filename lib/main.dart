import 'package:bhc/view/auth/initialpage.dart';
import 'package:bhc/view/bhc1/projectscreen.dart';
import 'package:bhc/view/bhc2/home.dart';
import 'package:bhc/view/sitebuilder/sitebuilderhomepage.dart';
import 'package:bhc/view_model/auth_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Retrieve login state before launching the app
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.reload(); // Ensure the latest value is read
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  print("Main: isLoggedIn = $isLoggedIn");
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  print("Main: isLoggedIn = $isLoggedIn, userEmail = $userEmail");

  runApp(MyApp(isLoggedIn: isLoggedIn, userEmail: userEmail));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userEmail;
  const MyApp({super.key, required this.isLoggedIn, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: false),
        initialRoute: isLoggedIn
            ? (userEmail != null && userEmail!.contains('@bhc')
                ? '/siteBuilderHome'
                : '/home')
            : '/initial',
        routes: {
          '/initial': (context) => const InitialPage(),
          '/home': (context) => const HomeView(),
          '/siteBuilderHome': (context) => const SiteBuilderHome(),
        },
      ),
    );
  }
}
