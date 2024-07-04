import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gapWidth;

  const DottedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gapWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    double currentPosition = 0.0;
    while (currentPosition < size.width) {
      canvas.drawLine(Offset(currentPosition, 0.0),
          Offset(currentPosition + strokeWidth, 0.0), paint);
      currentPosition += strokeWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  int quota = 0;
  int quantity = 0;

  Timestamp? timestamp;

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            elevation: 0,
            backgroundColor: Color.fromRGBO(196, 13, 15, 1),
            toolbarHeight: 0,
          ),
        ];
      },
      body: Scaffold(
        backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Tiket saya\n",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.width / 16.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextSpan(
                        text:
                            "Semua tiket pertandingan yang sudah aktif dan menunggu pembayaran",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width / 26,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('tickets')
                      .where('uid',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                      .where('ticketStatus', isEqualTo: 'pending')
                      .where('countdownPayment', isGreaterThan: Timestamp.now())
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!.docs.isEmpty
                          ? const SizedBox(
                              height: 20,
                            )
                          : Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Menunggu pembayaran',
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 15),
                                  height: 272,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        timestamp = snapshot.data!.docs[index]
                                            ['countdownPayment'];
                                        final targetDateTime = timestamp!
                                            .toDate(); // Convert Timestamp to DateTime
                                        Duration remainingTime =
                                            calculateRemainingTime(
                                                targetDateTime);
                                        timer?.cancel();
                                        timer = Timer.periodic(
                                            const Duration(seconds: 1), (t) {
                                          setState(() {
                                            remainingTime =
                                                calculateRemainingTime(
                                                    targetDateTime);
                                            // Check if countdown reached 0 (optional logic)
                                          });
                                        });
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 5,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          child: InkWell(
                                            onTap: () {},
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      60,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: snapshot.data!
                                                                    .docs[index]
                                                                [
                                                                'paymentStatus'] ==
                                                            'verifikasi'
                                                        ? 14
                                                        : 0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: snapshot.data!
                                                                    .docs[index]
                                                                [
                                                                'paymentStatus'] ==
                                                            'verifikasi'
                                                        ? Colors.amber.shade100
                                                        : const Color.fromRGBO(
                                                            196, 13, 15, 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: snapshot.data!
                                                                  .docs[index][
                                                              'paymentStatus'] ==
                                                          'verifikasi'
                                                      ? const Text(
                                                          'Sedang dalam verifikasi',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        )
                                                      : ListTile(
                                                          dense: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          title: const Text(
                                                            'Sisa waktu pelunasan',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          trailing: Text(
                                                            remainingTime
                                                                .toString()
                                                                .split('.')[0],
                                                            style: TextStyle(
                                                              color: const Color
                                                                  .fromRGBO(196,
                                                                  13, 15, 1),
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  25,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
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
                                                const SizedBox(height: 5),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      60,
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
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      60,
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
                                        );
                                      }),
                                ),
                              ],
                            );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Tiket Aktif',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tickets')
                            .where('uid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('paymentStatus', isEqualTo: 'lunas')
                            .where('ticketStatus', isEqualTo: 'aktif')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!.docs.isEmpty
                                ? Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 150,
                                        ),
                                        Text(
                                          'Belum Ada Tiket Yang Tersimpan',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  22.5,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Ayo pesan tiket pertandingan mu, tiket kamu akan ditampilkan disini.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints.tightFor(),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: snapshot.data!.docs.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade600
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: ListTile(
                                                    dense: true,
                                                    horizontalTitleGap: 10,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    leading: Icon(
                                                      FluentIcons
                                                          .info_20_filled,
                                                      color:
                                                          Colors.blue.shade800,
                                                    ),
                                                    title: Text(
                                                      snapshot.data!.docs[index]
                                                          ['orderName'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          height: 0,
                                                          color: Colors
                                                              .blue.shade800,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      snapshot.data!.docs[index]
                                                          ['orderEmail'],
                                                      style:
                                                          GoogleFonts.poppins(),
                                                    ),
                                                    trailing: Text(
                                                      'Rp ${double.parse(snapshot.data!.docs[index]['totalPrice'].toString()).toStringAsFixed(3)} ',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        textStyle: TextStyle(
                                                          height: 0,
                                                          color: Colors
                                                              .blue.shade800,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              27.5,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  child: ListTile(
                                                    dense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    subtitle: RichText(
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                'Kode Pesanan  ',
                                                            style: TextStyle(
                                                              color: Colors.grey
                                                                  .shade800,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: snapshot.data!
                                                                .docs[index].id,
                                                            style:
                                                                const TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      196,
                                                                      13,
                                                                      15,
                                                                      1),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    title: Text(
                                                      snapshot.data!.docs[index]
                                                          ['tribun'],
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    trailing: Text(
                                                      '${snapshot.data!.docs[index]['quantity'].toString()}  ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  child: ListTile(
                                                    dense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    leading: const Icon(
                                                        Icons.stadium_rounded),
                                                    title: Text(
                                                      snapshot
                                                          .data!
                                                          .docs[index]
                                                              ['stadium']
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  child: CustomPaint(
                                                    painter: DottedLinePainter(
                                                        color: Colors.grey,
                                                        strokeWidth: 2.0),
                                                    size: Size(double.infinity,
                                                        1.0), // Adjust height to desired thickness
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  child: ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Text(
                                                      snapshot.data!.docs[index]
                                                          ['event'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      DateFormat(
                                                              'EEEE, dd MMMM yyyy • HH:mm WIB',
                                                              'id')
                                                          .format(
                                                        DateFormat(
                                                                'yyyy-MM-dd HH.mm',
                                                                'id')
                                                            .parse(
                                                          snapshot.data!
                                                                  .docs[index]
                                                              ['matchTime'],
                                                        ),
                                                      ),
                                                      style: const TextStyle(
                                                        color: Color.fromRGBO(
                                                            196, 13, 15, 1),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 25,
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            4,
                                                        child: StreamBuilder(
                                                          stream:
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'logo')
                                                                  .doc(
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'home'],
                                                                  )
                                                                  .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Image.network(
                                                                    snapshot.data![
                                                                        'logoUrl'],
                                                                    height: MediaQuery.of(context)
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
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      height:
                                                                          0.9,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
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
                                                      const Text(
                                                        'VS',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          height: 0.9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            4,
                                                        child: StreamBuilder(
                                                          stream:
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'logo')
                                                                  .doc(
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'away'],
                                                                  )
                                                                  .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                .hasData) {
                                                              return Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Image.network(
                                                                    snapshot.data![
                                                                        'logoUrl'],
                                                                    height: MediaQuery.of(context)
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
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      height:
                                                                          0.9,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
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
                                                ),
                                                const Divider(),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                          .width,
                                                      40,
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  child: const Text(
                                                    'CETAK E-TIKET',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
