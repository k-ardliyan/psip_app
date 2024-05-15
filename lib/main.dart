import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/utils.dart';
import 'package:psip_app/screen/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:psip_app/screen/verifyemail_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: Utils.messengerKey,
      title: 'PSIP APP',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const PSIPAPP(),
    );
  }
}

class PSIPAPP extends StatelessWidget {
  const PSIPAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            const Center(
              child: Text("Terjadi kesalahan"),
            );
          } else if (snapshot.hasData) {
            return const VerifyScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
