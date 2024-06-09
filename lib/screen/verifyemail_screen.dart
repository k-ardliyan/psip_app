import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/bottom_bar.dart';
import 'package:psip_app/model/utils.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) {
          checkEmailVerified();
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResendEmail = false;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        canResendEmail = true;
      });
    } catch (e) {
      Utils.showSnackBar(
        e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const BottomNavBar()
        : Scaffold(
            body: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Verifikasi email\n",
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const TextSpan(
                            text:
                                "Email verifikasi telah dikirim ke email Anda.\nSilahkan buka kotak pesan email dan klik tautan\nuntuk verifikasi agar aplikasi dapat digunakan.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                      fixedSize: Size(
                        MediaQuery.of(context).size.width,
                        45,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      sendVerificationEmail();
                    },
                    icon: const Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Kirim ulang email",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
