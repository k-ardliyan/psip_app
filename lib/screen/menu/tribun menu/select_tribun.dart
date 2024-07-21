import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/tribun%20menu/personal_information.dart';

class SelectTribun extends StatefulWidget {
  const SelectTribun({super.key, required this.data});
  final QueryDocumentSnapshot data;

  @override
  State<SelectTribun> createState() => _SelectTribunState();
}

class _SelectTribunState extends State<SelectTribun> {
  int total = 0;
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

  Future<int> getTotalField() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('tickets')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('teamMatch', isEqualTo: widget.data.id)
        .where('matchTime', isEqualTo: widget.data['dateTime']);
    final snapshot = await collectionRef.get();

    for (var doc in snapshot.docs) {
      total +=
          doc['quantity'] as int; // Assuming the field holds numeric values
    }

    if (kDebugMode) {
      print(total);
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _deleteOldData();
    getTotalField().then((context) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ];
        },
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('match')
              .doc(widget.data.id)
              .collection('tribun')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: total == 3
                                  ? "Pengumuman!!\n"
                                  : "Pilih tribun\n",
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
                              text: total == 3
                                  ? 'Mohon maaf Anda telah mencapai batas maksimal pemesanan tiket, terima kasih atas kesetiaan dan kepercayaan anda terhadap layanan kami.'
                                  : 'Silahkan pilih tribun sesuai keinginan Anda dan sesuai ketersediaan tiket, setiap pengguna dapat memesan tiket dengan jumlah maksimal 3 tiket tiap pertandingan.',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.width / 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (total < 3) ...{
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.center,
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
                              offset: const Offset(
                                  0, 1.5), // Adjust the position of the shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('logo')
                                    .doc(widget.data['home'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          snapshot.data!['logoUrl'],
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
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            height: 0.9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.data['event'],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(196, 13, 15, 1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.data['date'],
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
                                    color: Color.fromRGBO(196, 13, 15, 1),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.data['time'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 4,
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('logo')
                                    .doc(widget.data['away'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          snapshot.data!['logoUrl'],
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
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            height: 0.9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          if (snapshot.hasData) {
                            return GestureDetector(
                              onTap: snapshot.data!.docs[index]['quota'] < 1 ||
                                      total == 3
                                  ? null
                                  : () {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Quantity(
                                              data: snapshot.data!.docs[index],
                                              match: widget.data,
                                              totalQuantity: total,
                                            );
                                          });
                                    },
                              child: Container(
                                margin: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 10,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          snapshot.data!.docs[index].id,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                22.5,
                                          ),
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Harga\n',
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    'Rp ${snapshot.data!.docs[index]['price'] == 0 ? snapshot.data!.docs[index]['price'] : double.parse(snapshot.data!.docs[index]['price'].toString()).toStringAsFixed(3)}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          22.5,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' /tiket',
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                  4,
                                              25,
                                            ),
                                          ),
                                          onPressed: snapshot.data!.docs[index]
                                                          ['quota'] <
                                                      1 ||
                                                  total == 3
                                              ? null
                                              : () {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return Quantity(
                                                          data: snapshot.data!
                                                              .docs[index],
                                                          match: widget.data,
                                                          totalQuantity: total,
                                                        );
                                                      });
                                                },
                                          child: Text(
                                            snapshot.data!.docs[index]
                                                        ['quota'] <
                                                    1
                                                ? 'HABIS'
                                                : 'BELI',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          snapshot.data!.docs[index]['quota'] <
                                                  20
                                              ? 'Sisa ${snapshot.data!.docs[index]['quota']} tiket'
                                              : 'Tersedia',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: snapshot.data!.docs[index]
                                                        ['quota'] <
                                                    20
                                                ? Colors.red
                                                : Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    } else ...{
                      const SizedBox.shrink(),
                    }
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

class Quantity extends StatefulWidget {
  const Quantity(
      {super.key,
      required this.data,
      required this.match,
      required this.totalQuantity});
  final QueryDocumentSnapshot data;
  final QueryDocumentSnapshot match;
  final int totalQuantity;

  @override
  State<Quantity> createState() => _QuantityState();
}

class _QuantityState extends State<Quantity> {
  int quantity = 0; // Initial quantity
  int maxQuantity = 3;
  int price = 0; // Initial quantity
  int total = 0;
  int quota = 0;
  String code = '';

  void incrementQuantity() {
    final newQuantity = quantity + 1;
    if (newQuantity <= widget.data['quota'] && newQuantity <= maxQuantity) {
      setState(() {
        quantity = newQuantity;
        total = price * quantity;
      });
    }
  }

  void decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
        total = price * quantity;
      });
    }
  }

  String generateTicketCode() {
    final random = Random();
    final prefix = widget.data.id == 'TRIBUN TIMUR'
        ? 'ET-'
        : widget.data.id == 'TRIBUN SELATAN'
            ? 'SH-'
            : widget.data.id == 'TRIBUN BARAT'
                ? 'WT-'
                : widget.data.id == 'TRIBUN UTARA'
                    ? 'NH-'
                    : '';

    // Generate random uppercase letters (A-Z)
    final letters = String.fromCharCodes(
        List.generate(3, (index) => random.nextInt(26) + 65));

    // Generate random digits (0-9)
    final digits = List.generate(3, (index) => random.nextInt(10)).join();

    return '$prefix$letters$digits';
  }

  Future<void> setTicket(String code) async {
    return await FirebaseFirestore.instance.collection('tickets').doc(code).set(
      {
        'paymentStatus': '',
        'paymentMethod': '',
        'paymentCode': '',
        'paymentDate': '',
        'ticketCode': code,
        'ticketStatus': '',
        'quantity': quantity,
        'totalPrice': total,
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'tribun': widget.data.id,
        'orderDate': DateFormat('yyyy-MM-dd HH:mm', 'id_ID').format(
          DateTime.now().toUtc().add(
                const Duration(hours: 7),
              ),
        ),
        'orderName': '',
        'orderEmail': '',
        'orderPhone': '',
        'orderAddress': '',
        'matchTime': widget.match['dateTime'],
        'event': widget.match['event'],
        'teamMatch': widget.match.id,
        'home': widget.match['home'],
        'away': widget.match['away'],
        'stadium': widget.match['stadium'],
      },
    ).whenComplete(() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return PopScope(
            onPopInvoked: (didPop) async {
              return await FirebaseFirestore.instance
                  .collection('tickets')
                  .doc(code)
                  .delete()
                  .whenComplete(() {
                Get.back();
              });
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: PersonalInformation(
                code: code,
              ),
            ),
          );
        }),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    code = generateTicketCode();
    maxQuantity = maxQuantity - widget.totalQuantity;
    quota = widget.data['quota'];
    price = widget.data['price'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height / 4,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.data.id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width / 22.5,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  disabledBackgroundColor:
                      const Color.fromRGBO(196, 13, 15, 0.5),
                  backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                  fixedSize: Size(
                    MediaQuery.of(context).size.width / 3,
                    40,
                  ),
                ),
                onPressed: quantity == 0
                    ? null
                    : () {
                        setTicket(code);
                      },
                child: const Text(
                  'Selanjutnya',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp.${total == 0 ? total : total.toStringAsFixed(3)}(x$quantity)',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 22.5,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      decrementQuantity();
                    },
                    icon: const Icon(Icons.remove_circle),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Text(
                      '$quantity',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      incrementQuantity();
                    },
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
