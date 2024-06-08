import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        if (value.exists) {
          user = UserModel.fromMap(value.data()!);
        }
        setState(() {});
      });
    }
  }

  final double coverHeight = 230;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                buildCoverImage(),
                Positioned(
                  top: coverHeight / 1.75,
                  child: Card(
                    color: Colors.white,
                    child: SizedBox(
                      height: coverHeight / 1.25,
                      width: MediaQuery.of(context).size.width - 25,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  child: Text(
                                    user?.displayName
                                            ?.substring(0, 2)
                                            .toUpperCase() ??
                                        '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 25,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${user?.displayName?.toUpperCase() ?? '*****'}\n",
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: FirebaseAuth
                                              .instance.currentUser?.uid ??
                                          '*****',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width,
                                  45,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                iconColor: Colors.black87,
                              ),
                              icon: const Icon(FluentIcons.person_20_filled),
                              label: Text(
                                "Lihat Profil",
                                style: GoogleFonts.poppins(
                                  textStyle:
                                      const TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: coverHeight / 2,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fixedSize: Size(MediaQuery.of(context).size.width - 25, 45),
              ),
              child: ListTile(
                dense: true,
                horizontalTitleGap: 10,
                leading: const Icon(FluentIcons.password_reset_48_regular),
                title: Text(
                  "Ganti Kata Sandi",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                trailing: const Icon(FluentIcons.arrow_right_48_regular),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fixedSize: Size(MediaQuery.of(context).size.width - 25, 45),
              ),
              child: ListTile(
                dense: true,
                horizontalTitleGap: 10,
                leading: const Icon(
                    FluentIcons.text_bullet_list_square_clock_20_regular),
                title: Text(
                  "Riwayat Pesanan",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                trailing: const Icon(FluentIcons.arrow_right_48_regular),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: () {},
                  icon: const Icon(FluentIcons.person_support_24_regular),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(FluentIcons.arrow_exit_20_regular),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCoverImage() {
    return Container(
      height: coverHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Color.fromRGBO(196, 13, 15, 1), BlendMode.hardLight),
          image: AssetImage('assets/images/stadion.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        blendMode: BlendMode.darken,
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: const SizedBox(),
      ),
    );
  }
}
