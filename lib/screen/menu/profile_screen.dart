import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double coverHeight = 230;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
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
                            backgroundColor: Colors.primaries[
                                Random().nextInt(Colors.primaries.length)],
                            child: Text(
                              FirebaseAuth.instance.currentUser!.displayName!
                                  .substring(0, 2)
                                  .toUpperCase(),
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
                                    "${FirebaseAuth.instance.currentUser!.displayName!.toUpperCase()}\n",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: FirebaseAuth.instance.currentUser!.uid
                                    .toString(),
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
                            textStyle: const TextStyle(color: Colors.black87),
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
