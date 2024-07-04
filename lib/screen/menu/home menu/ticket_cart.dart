import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/tribun%20menu/payment_method.dart';

class TicketCart extends StatefulWidget {
  const TicketCart({super.key});

  @override
  State<TicketCart> createState() => _TicketCartState();
}

class _TicketCartState extends State<TicketCart> {
  Timestamp? timestamp;

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _deleteOldData();
  }

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

  Duration calculateRemainingTime(DateTime targetDateTime) {
    if (targetDateTime.toString().isEmpty) {
      // Handle null targetDateTime (e.g., return Duration.zero or throw an exception)
      return Duration.zero;
    }
    return targetDateTime
            .difference(
              DateTime.now(),
            )
            .isNegative
        ? Duration.zero
        : targetDateTime.difference(
            DateTime.now(),
          );
  }

  Future<void> minQuota(teamMatch, tribun, code, jumlah) async {
    setState(() {
      quantity = jumlah;
    });
    await FirebaseFirestore.instance
        .collection('match')
        .doc(teamMatch)
        .collection('tribun')
        .doc(tribun)
        .get()
        .then((onValue) async {
      if (onValue.exists) {
        quota = onValue.data()!['quota'];
      }
      setState(() {
        quota = quota - quantity;
      });
      if (onValue.data()!['quota'] < quantity) {
        FirebaseFirestore.instance
            .collection('tickets')
            .doc(code)
            .delete()
            .then((onValue) {
          Get.offAllNamed('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tiket habis!'),
            ),
          );
        });
      } else {
        await FirebaseFirestore.instance
            .collection('match')
            .doc(teamMatch)
            .collection('tribun')
            .doc(tribun)
            .update({'quota': quota}).whenComplete(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PaymentMethod(code: code);
              },
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tickets')
              .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('ticketStatus', isEqualTo: 'keranjang')
              .where('countdownPayment', isGreaterThan: Timestamp.now())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!.docs.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Pilih pesanan yang ingin dibayar",
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                16.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints.tightFor(),
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    timestamp = snapshot.data!.docs[index]
                                        ['countdownPayment'];
                                    final targetDateTime = timestamp!
                                        .toDate(); // Convert Timestamp to DateTime
                                    Duration remainingTime =
                                        calculateRemainingTime(targetDateTime);
                                    timer?.cancel();
                                    timer = Timer.periodic(
                                        const Duration(seconds: 1), (t) {
                                      setState(() {
                                        remainingTime = calculateRemainingTime(
                                            targetDateTime);
                                        // Check if countdown reached 0 (optional logic)
                                      });
                                    });
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(
                                                    0.75), // Adjust shadow color and opacity
                                                blurRadius: 1,
                                                spreadRadius: -0.5,
                                                offset: const Offset(
                                                  0,
                                                  1.5,
                                                ), // Adjust the position of the shadow
                                              ),
                                            ],
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  scrollControlDisabledMaxHeightRatio:
                                                      0.3,
                                                  context: context,
                                                  builder: (context) {
                                                    return Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 15,
                                                        horizontal: 20,
                                                      ),
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        title: const Text(
                                                          'Total Harga',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          'Rp ${double.parse(
                                                            snapshot
                                                                .data!
                                                                .docs[index][
                                                                    'totalPrice']
                                                                .toString(),
                                                          ).toStringAsFixed(3)}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        trailing:
                                                            ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            shape:
                                                                const StadiumBorder(),
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    196,
                                                                    13,
                                                                    15,
                                                                    1),
                                                            tapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                          ),
                                                          onPressed: () {
                                                            minQuota(
                                                                snapshot.data!
                                                                            .docs[
                                                                        index][
                                                                    'teamMatch'],
                                                                snapshot.data!
                                                                            .docs[
                                                                        index]
                                                                    ['tribun'],
                                                                snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id,
                                                                snapshot.data!
                                                                            .docs[
                                                                        index][
                                                                    'quantity']);
                                                          },
                                                          child: Text(
                                                            'BAYAR',
                                                            style: GoogleFonts
                                                                .poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    top: 15,
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromRGBO(
                                                        196, 13, 15, 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: const Text(
                                                      'Sisa waktu pelunasan',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                      remainingTime
                                                          .toString()
                                                          .split('.')[0],
                                                      style: TextStyle(
                                                        color: const Color
                                                            .fromRGBO(
                                                            196, 13, 15, 1),
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    '${snapshot.data!.docs[index]['tribun']} • ${DateFormat('dd MMMM yyyy • HH:mm WIB', 'id').format(
                                                      DateFormat(
                                                              'yyyy-MM-dd HH.mm',
                                                              'id')
                                                          .parse(
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['matchTime'],
                                                      ),
                                                    )}',
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    snapshot.data!.docs[index]
                                                        ['teamMatch'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              22.5,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: ListTile(
                                                    minVerticalPadding: 0,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      snapshot.data!.docs[index]
                                                          ['orderName'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      snapshot.data!.docs[index]
                                                          ['orderEmail'],
                                                    ),
                                                    trailing: Text(
                                                      snapshot
                                                          .data!.docs[index].id,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: const Color
                                                            .fromRGBO(
                                                            196, 13, 15, 1),
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: const Text(
                                                      'Total Harga',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                        '${snapshot.data!.docs[index]['quantity']}x Tiket'),
                                                    trailing: Text(
                                                      'Rp ${double.parse(
                                                        snapshot
                                                            .data!
                                                            .docs[index]
                                                                ['totalPrice']
                                                            .toString(),
                                                      ).toStringAsFixed(3)}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            fixedSize: Size(
                                              MediaQuery.of(context).size.width,
                                              40,
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    title: const Text(
                                                      'Batalkan pesanan',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: const Text(
                                                      'Apakah Anda yakin untuk membatalkan pemesanan tiket?',
                                                    ),
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    actions: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Get.back();
                                                        },
                                                        child: Text(
                                                          'BELUM',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: Colors
                                                                .grey.shade800,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromRGBO(196,
                                                                  13, 15, 1),
                                                        ),
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'tickets')
                                                              .doc(snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id)
                                                              .delete()
                                                              .then((_) {
                                                            Get.back();
                                                          });
                                                        },
                                                        child: Text(
                                                          'YA',
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Text(
                                            'BATALKAN PESANAN',
                                            style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    196, 13, 15, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.topLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Keranjang kosong\n",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 16.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextSpan(
                              text:
                                  "Silahkan tambah tiket pertandingan ke dalam keranjang",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
