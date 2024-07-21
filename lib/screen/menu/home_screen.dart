import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/bottom_bar.dart';
import 'package:psip_app/model/user_model.dart';
import 'package:psip_app/screen/menu/ticket%20menu/ticket.dart';
import 'package:psip_app/screen/menu/tribun%20menu/select_tribun.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel user = UserModel();

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
          if (onValue.data()!['ticketStatus'] == 'keranjang') {
            collection.doc(doc.id).delete();
          } else {
            await FirebaseFirestore.instance
                .collection('match')
                .doc(doc['teamMatch'])
                .collection('tribun')
                .doc(doc['tribun'])
                .update({'quota': quota}).whenComplete(() {
              collection.doc(doc.id).delete();
            });
          }
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
    _deleteOldData;
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      user = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            toolbarHeight: 90,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Selamat datang,\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text:
                        snapshot.data!['displayName'].toUpperCase() ?? '******',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Color.fromRGBO(196, 13, 15, 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (snapshot.data!['role'] != 'User')
                IconButton(
                  iconSize: 30,
                  onPressed: () {
                    Get.toNamed('/scan-qr');
                  },
                  icon: const Icon(
                    FluentIcons.scan_qr_code_24_regular,
                    color: Color.fromRGBO(196, 13, 15, 1),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: IconButton(
                  iconSize: 30,
                  onPressed: () {
                    _deleteOldData;
                    Get.toNamed('/ticket-cart');
                  },
                  icon: const Icon(
                    FluentIcons.cart_24_filled,
                    color: Color.fromRGBO(196, 13, 15, 1),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('tickets')
                        .where('uid',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('paymentStatus', isEqualTo: 'lunas')
                        .where('ticketStatus', isEqualTo: 'aktif')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!.docs.isEmpty
                            ? const SizedBox.shrink()
                            : Column(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tiket aktif',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Get.put(BottomBarController())
                                                .changeIndex(1);
                                          },
                                          child: Text(
                                            'Lihat semua',
                                            style: GoogleFonts.poppins(
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    25,
                                                color: const Color.fromRGBO(
                                                    196, 13, 15, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    constraints:
                                        const BoxConstraints(maxHeight: 75),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                40,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: ListTile(
                                            onTap: () {
                                              if (DateTime.now().isAfter(
                                                DateTime.parse(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(
                                                    DateFormat(
                                                            'yyyy-MM-dd HH.mm')
                                                        .parse(snapshot.data!
                                                                .docs[index]
                                                            ['matchTime'])
                                                        .subtract(
                                                          const Duration(
                                                              hours: 2),
                                                        ),
                                                  ),
                                                ),
                                              )) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return ETICKET(
                                                          data: snapshot.data!
                                                              .docs[index]);
                                                    },
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'E-ticket dapat dibuka 2 jam sebelum pertandingan'),
                                                  ),
                                                );
                                              }
                                            },
                                            title: RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        '${snapshot.data!.docs[index]['orderName']} • ',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: snapshot
                                                        .data!.docs[index].id,
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          196, 13, 15, 1),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            subtitle: Text(
                                              snapshot.data!.docs[index]
                                                  ['teamMatch'],
                                            ),
                                            trailing: const Icon(FluentIcons
                                                .chevron_right_48_filled),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sosial media',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(context).size.width / 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RawMaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: Colors.grey.shade900,
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                      onPressed: () async {
                        if (await canLaunchUrl(
                          Uri.parse(
                              'https://www.instagram.com/psipofficial?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw=='),
                        )) {
                          await launchUrl(
                            Uri.parse(
                                'https://www.instagram.com/psipofficial?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw=='),
                          );
                        } else {
                          throw 'Could not launch https://www.instagram.com/psipofficial?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==';
                        }
                      },
                      child: const Icon(
                        FontAwesomeIcons.instagram,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    RawMaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: Colors.grey.shade900,
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                      onPressed: () async {
                        if (await canLaunchUrl(
                          Uri.parse('https://x.com/officialpsip'),
                        )) {
                          await launchUrl(
                            Uri.parse('https://x.com/officialpsip'),
                          );
                        } else {
                          throw 'Could not launch https://x.com/officialpsip';
                        }
                      },
                      child: const Icon(
                        FontAwesomeIcons.xTwitter,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    RawMaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      fillColor: Colors.grey.shade900,
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                      onPressed: () async {
                        if (await canLaunchUrl(
                          Uri.parse('https://www.facebook.com/psippml'),
                        )) {
                          await launchUrl(
                            Uri.parse('https://www.facebook.com/psippml'),
                          );
                        } else {
                          throw 'Could not launch https://www.facebook.com/psippml';
                        }
                      },
                      child: const Icon(
                        FontAwesomeIcons.facebook,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Jadwal',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(context).size.width / 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('match')
                      .where(
                        'dateTime',
                        isGreaterThan: DateFormat('yyyy-MM-dd HH.mm').format(
                          DateTime.now().add(
                            const Duration(hours: 12),
                          ),
                        ),
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!.docs.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height / 10,
                              child: const Center(
                                child: Text('Belum ada jadwal pertandingan'),
                              ),
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints.tightFor(),
                              child: ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  if (snapshot.hasData) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        bottom: 10,
                                      ),
                                      height: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(
                                                1), // Adjust shadow color and opacity
                                            blurRadius: 1,
                                            spreadRadius: -0.5,
                                            offset: const Offset(0,
                                                1.5), // Adjust the position of the shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('logo')
                                                  .doc(snapshot.data!
                                                      .docs[index]['home'])
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.network(
                                                        snapshot
                                                            .data!['logoUrl'],
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            4.5,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${snapshot.data!['nameTeam']}\n${snapshot.data!['homeTown']}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          height: 0.9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                snapshot.data!.docs[index]
                                                    ['event'],
                                                style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      196, 13, 15, 1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('EEEE, dd MMMM yyyy',
                                                        'id')
                                                    .format(
                                                  DateFormat('yyyy-MM-dd HH.mm',
                                                          'id')
                                                      .parse(
                                                    snapshot.data!.docs[index]
                                                        ['dateTime'],
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Text(
                                                'KICK OFF',
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      196, 13, 15, 1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('HH:mm WIB', 'id')
                                                    .format(
                                                  DateFormat('yyyy-MM-dd HH.mm',
                                                          'id')
                                                      .parse(
                                                    snapshot.data!.docs[index]
                                                        ['dateTime'],
                                                  ),
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              ElevatedButton(
                                                onPressed:
                                                    snapshot.data!.docs[index]
                                                                ['open'] ==
                                                            false
                                                        ? null
                                                        : () async {
                                                            int total = 0;
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'tickets')
                                                                .where('uid',
                                                                    isEqualTo: FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                        ?.uid)
                                                                .where(
                                                                    'teamMatch',
                                                                    isEqualTo: snapshot
                                                                        .data!
                                                                        .docs[
                                                                            index]
                                                                        .id)
                                                                .where(
                                                                    'matchTime',
                                                                    isEqualTo: snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'dateTime'])
                                                                .get()
                                                                .then(
                                                                    (onValue) {
                                                              for (var doc
                                                                  in onValue
                                                                      .docs) {
                                                                total += doc[
                                                                        'quantity']
                                                                    as int; // Assuming the field holds numeric values
                                                              }
                                                              if (kDebugMode) {
                                                                print(total);
                                                              }
                                                              return total;
                                                            }).whenComplete(() {
                                                              _deleteOldData;
                                                              if (total == 3) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Maksimal 3 tiket tiap pertandingan'),
                                                                  ),
                                                                );
                                                              } else {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                                      return SelectTribun(
                                                                        data: snapshot
                                                                            .data!
                                                                            .docs[index],
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              }
                                                            });
                                                          },
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  disabledBackgroundColor:
                                                      const Color.fromRGBO(
                                                          196, 13, 15, 0.5),
                                                  backgroundColor:
                                                      const Color.fromRGBO(
                                                          196, 13, 15, 1),
                                                  fixedSize: Size(
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3,
                                                    40,
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  child: Text(
                                                    snapshot.data!.docs[index]
                                                                ['open'] ==
                                                            false
                                                        ? 'SEGERA'
                                                        : 'BELI TIKET',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                4,
                                            child: StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('logo')
                                                  .doc(snapshot.data!
                                                      .docs[index]['away'])
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Image.network(
                                                        snapshot
                                                            .data!['logoUrl'],
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            4.5,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${snapshot.data!['nameTeam']}\n${snapshot.data!['homeTown']}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          height: 0.9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
