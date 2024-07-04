import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/tribun%20menu/payment_method.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.code});
  final String code;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  int quota = 0;
  int quantity = 0;
  String teamMatch = '';
  String tribun = '';
  bool onChecked = false;

  Future<void> minQuota() async {
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
            .doc(widget.code)
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
                return PaymentMethod(code: widget.code);
              },
            ),
          );
        });
      }
    });
  }

  Future<DateTime?> getTargetDateTimeFromFirestore() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.code)
        .get();
    if (docSnapshot.exists) {
      final timestamp = docSnapshot.data()!['countdownPayment'] as Timestamp;
      return timestamp.toDate();
    } else {
      return null; // Handle the case where no document exists
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

  void _showPaymentDeadlineDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // prevent user from dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Batas Waktu Pemesanan Telah Habis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
              'Waktu yang diberikan untuk melakukan pemesanan tiket Anda telah habis.'),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
              ),
              onPressed: () {
                Get.offAllNamed("/");
              },
              child: const Text(
                'TUTUP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.code)
        .get()
        .then((onValue) {
      if (onValue.exists) {
        teamMatch = onValue.data()!['teamMatch'];
        tribun = onValue.data()!['tribun'];
        quantity = onValue.data()!['quantity'];
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.code)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return !snapshot.data!.exists
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : PopScope(
                    canPop: false,
                    onPopInvoked: (didPop) async {
                      return showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              title: const Text('Batalkan pesanan'),
                              content: const Text(
                                'Apakah Anda yakin untuk membatalkan pemesanan tiket?',
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text(
                                    'BELUM',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor:
                                        const Color.fromRGBO(196, 13, 15, 1),
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('tickets')
                                        .doc(snapshot.data!.id)
                                        .delete()
                                        .then((_) {
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    });
                                  },
                                  child: Text(
                                    'YA',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 0,
                      ),
                      backgroundColor: Colors.white,
                      body: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            StreamBuilder<DateTime?>(
                                stream:
                                    Stream.periodic(const Duration(seconds: 1))
                                        .asyncMap(
                                  (_) => getTargetDateTimeFromFirestore(),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final remainingTime =
                                        calculateRemainingTime(snapshot.data!);
                                    if (remainingTime.inSeconds <= 1) {
                                      // Start a timer to show the dialog after 1 second (adjust as needed)
                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        _showPaymentDeadlineDialog();
                                      });
                                    }
                                  } else if (!snapshot.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Selesaikan pemesanan dalam',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                22.5,
                                          ),
                                        ),
                                        Text(
                                          calculateRemainingTime(snapshot.data!)
                                              .toString()
                                              .split('.')[0],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                22.5,
                                            color: const Color.fromRGBO(
                                                196, 13, 15, 1),
                                          ),
                                        ),
                                        Text(
                                          'Batas Akhir Pemesanan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                27.5,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('EEEE, d MMMM yyyy HH:mm',
                                                  'id')
                                              .format(snapshot.data!),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            const Divider(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Rincian pesanan",
                                      style: GoogleFonts.poppins(
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
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
                                      0,
                                      1.5,
                                    ), // Adjust the position of the shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('dd MMMM yyyy • HH:mm WIB', 'id')
                                        .format(
                                      DateFormat('yyyy-MM-dd HH.mm', 'id')
                                          .parse(
                                        snapshot.data!.data()!['matchTime'],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    snapshot.data!.data()!['teamMatch'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              22.5,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data!
                                              .data()!['orderName']
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                27.5,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              snapshot.data!
                                                  .data()!['tribun']
                                                  .toString()
                                                  .toLowerCase(),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '(${snapshot.data!.data()!['quantity'].toString().toLowerCase()}x)',
                                                ),
                                                const Text(
                                                  'tiket ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Total'),
                                              Text(
                                                'Rp ${double.parse(
                                                  snapshot.data!
                                                      .data()!['totalPrice']
                                                      .toString(),
                                                ).toStringAsFixed(3)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              horizontalTitleGap: 0,
                              leading: Radio(
                                toggleable: true,
                                fillColor: const WidgetStatePropertyAll(
                                  Color.fromRGBO(196, 13, 15, 1),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                value: onChecked,
                                groupValue: true,
                                onChanged: (value) =>
                                    setState(() => onChecked = !onChecked),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Saya telah membaca dan setuju terhadap ',
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Syarat dan ketentuan pembelian tiket',
                                      style: TextStyle(
                                        color: Color.fromRGBO(196, 13, 15, 1),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor:
                                    const Color.fromRGBO(196, 13, 15, 1),
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width,
                                  45,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                if (onChecked) {
                                  minQuota();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Mohon centang persetujuan syarat dan ketentuan'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'BAYAR',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width,
                                  45,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () async {
                                if (onChecked) {
                                  await FirebaseFirestore.instance
                                      .collection('tickets')
                                      .doc(widget.code)
                                      .update({
                                    'ticketStatus': 'keranjang'
                                  }).whenComplete(() {
                                    Get.offAllNamed('/');
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Mohon centang persetujuan syarat dan ketentuan'),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'TAMBAH KE KERANJANG',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
