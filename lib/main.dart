import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:psip_app/model/utils.dart';
import 'package:psip_app/screen/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:psip_app/screen/forgot_sreen.dart';
import 'package:psip_app/screen/menu/home%20menu/ticket_cart.dart';
import 'package:psip_app/screen/menu/profile%20menu/change_password.dart';
import 'package:psip_app/screen/menu/profile%20menu/delete_user.dart';
import 'package:psip_app/screen/menu/profile%20menu/edit_profile.dart';
import 'package:psip_app/screen/menu/profile%20menu/history/history_screen.dart';
import 'package:psip_app/screen/menu/profile%20menu/profile_information.dart';
import 'package:psip_app/screen/menu/ticket%20menu/scan_qr.dart';
import 'package:psip_app/screen/verifyemail_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GoogleSignInProvider(),
        ),
      ],
      child: GetMaterialApp(
        scaffoldMessengerKey: Utils.messengerKey,
        title: 'PSIP APP',
        theme: ThemeData(
          textTheme: GoogleFonts.interTextTheme(),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
        ],
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/root': (context) => const MyApp(),
          '/': (context) => const PSIPApp(),
          '/auth-screen': (context) => const AuthScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify': (context) => const VerifyScreen(),
          '/profile-info': (context) => const ProfileInformation(),
          '/edit-profile': (context) => const EditProfile(),
          '/change-password': (context) => const ChangePassword(),
          '/history': (context) => const HistoryScreen(),
          '/delete-user': (context) => const DeleteUser(),
          '/scan-qr': (context) => const ScanQr(),
          '/ticket-cart': (context) => const TicketCart(),
        },
      ),
    );
  }
}

class PSIPApp extends StatelessWidget {
  const PSIPApp({super.key});

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

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    bool result = false;
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) return;

      _user = googleUser;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(
            {
              'uid': user.uid,
              'email': user.email,
              'address': '',
              'displayName': user.displayName,
              'gender': '',
              'phoneNumber': '',
              'photoURL': user.photoURL,
              'role': 'User',
            },
          );
        }
        result = true;
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }

    notifyListeners();
    return result;
  }

  Future logout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
