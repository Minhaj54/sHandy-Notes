import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes_hub/Admin%20Panel/new%20admin%20panel/upload%20pdf%20/admin_home_Page.dart';
import 'package:notes_hub/firebase_options.dart';
import 'package:notes_hub/navigation_page.dart';
import 'package:notes_hub/provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import 'helper_class/custum_page_tansition.dart';
import 'login/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Firebase Messaging
//  FirebaseMessaging messaging = FirebaseMessaging.instance;
//  await FirebaseAppCheck.instance.activate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'sHandy Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          shadowColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          color: Colors.deepPurpleAccent,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(60),
            backgroundColor: Colors.deepPurpleAccent,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(
                type: PageTransitionType.rightToLeftWithFade),
            TargetPlatform.iOS: CustomPageTransitionBuilder(
                type: PageTransitionType.rightToLeftWithFade),
          },
        ),
      ),
      home: const NavigationBaar(),
      // routes: {
      //   '/upload': (context) => const UploadPage(),
      //   '/login': (context) => const LoginWithPhoneNumber(),
      // },
    );
  }
}
