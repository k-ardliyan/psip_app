// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psip_app/main.dart';
import 'package:psip_app/model/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  int quota = 0;
  int quantity = 0;

  Future<void> _deleteOldData() async {
    final now = Timestamp.now();
    final collection = FirebaseFirestore.instance.collection('tickets');

    try {
      final querySnapshot = await collection
          .where('paymentStatus', isEqualTo: 'menunggu')
          .where('countdownPayment', isLessThanOrEqualTo: now)
          .get();
      for (var doc in querySnapshot.docs) {
        quantity = doc['quantity'];
        await FirebaseFirestore.instance
            .collection('match')
            .doc(doc['teamMatch'])
            .collection('tribun')
            .doc(doc['tribun'])
            .get()
            .then((onValue) async {
          quota = onValue.data()!['quota'];
          setState(() {
            quota = quota + quantity;
          });
          await FirebaseFirestore.instance
              .collection('match')
              .doc(doc['teamMatch'])
              .collection('tribun')
              .doc(doc['tribun'])
              .update({'quota': quota});
        }).whenComplete(() {
          collection.doc(doc.id).delete();
        });
      }
      if (kDebugMode) {
        print('Old documents deleted successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting old documents: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _deleteOldData();
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

  final double coverHeight = 200;

  Stream<DocumentSnapshot> getDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  launchWA() async {
    const url =
        'https://api.whatsapp.com/send?phone=6285700091637&text=Support+PSIP+PEMALANG%0A%0Ariffatiman%40gmail.com&type=phone_number&app_absent=0';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: getDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
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
                        top: coverHeight / 1.8,
                        child: Card(
                          color: Colors.white,
                          child: SizedBox(
                            height: coverHeight / 1.2,
                            width: MediaQuery.of(context).size.width - 40,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.grey.shade800,
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
                                                "${snapshot.data!['displayName'].toUpperCase() ?? '*****'}\n",
                                            style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: FirebaseAuth
                                                    .instance.currentUser?.uid
                                                    .substring(0, 8)
                                                    .toUpperCase() ??
                                                '*****',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: coverHeight / 9,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.toNamed('/profile-info');
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width,
                          40,
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
                  SizedBox(
                    height: coverHeight / 4.5,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 25,
                    child: ListTile(
                      onTap: () {
                        Get.toNamed('/change-password');
                      },
                      dense: true,
                      horizontalTitleGap: 10,
                      leading: IconButton.filled(
                        onPressed: null,
                        icon: const Icon(
                          FluentIcons.password_reset_48_regular,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          disabledBackgroundColor:
                              const Color.fromRGBO(196, 13, 15, 1),
                        ),
                      ),
                      title: Text(
                        "Ubah Kata Sandi",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: const Icon(FluentIcons.chevron_right_48_filled),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 25,
                    child: ListTile(
                      onTap: () {
                        Get.toNamed('/history');
                      },
                      dense: true,
                      horizontalTitleGap: 10,
                      leading: IconButton.filled(
                        onPressed: null,
                        icon: const Icon(
                          FluentIcons.text_bullet_list_square_clock_20_regular,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          disabledBackgroundColor:
                              const Color.fromRGBO(196, 13, 15, 1),
                        ),
                      ),
                      title: Text(
                        "Riwayat Pesanan",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: const Icon(FluentIcons.chevron_right_48_filled),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 25,
                    child: ListTile(
                      onTap: () {
                        launchWA();
                      },
                      dense: true,
                      horizontalTitleGap: 10,
                      leading: IconButton.filled(
                        onPressed: null,
                        icon: const Icon(
                          FluentIcons.person_support_24_regular,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          disabledBackgroundColor:
                              const Color.fromRGBO(196, 13, 15, 1),
                        ),
                      ),
                      title: Text(
                        "Layanan Pelanggan",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: const Icon(FluentIcons.chevron_right_48_filled),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 25,
                    child: ListTile(
                      onTap: () {
                        Provider.of<GoogleSignInProvider>(context,
                                listen: false)
                            .logout();
                      },
                      dense: true,
                      horizontalTitleGap: 10,
                      leading: IconButton.filled(
                        onPressed: null,
                        icon: const Icon(
                          FluentIcons.sign_out_20_regular,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          disabledBackgroundColor:
                              const Color.fromRGBO(196, 13, 15, 1),
                        ),
                      ),
                      title: Text(
                        "Keluar",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: const Icon(FluentIcons.chevron_right_48_filled),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
