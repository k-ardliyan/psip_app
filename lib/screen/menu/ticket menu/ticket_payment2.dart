import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/ticket%20menu/upload_proof.dart';

class TicketPayment2 extends StatefulWidget {
  const TicketPayment2({super.key, required this.code});
  final String code;

  @override
  State<TicketPayment2> createState() => _TicketPayment2State();
}

class _TicketPayment2State extends State<TicketPayment2> {
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
            'Batas Waktu Pembayaran Telah Habis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
              'Waktu yang diberikan untuk melakukan pembayaran tiket Anda telah habis.'),
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
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime?>(
        stream: Stream.periodic(const Duration(seconds: 1)).asyncMap(
          (_) => getTargetDateTimeFromFirestore(),
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final remainingTime = calculateRemainingTime(snapshot.data!);
            if (remainingTime.inSeconds <= 1) {
              // Start a timer to show the dialog after 1 second (adjust as needed)
              Future.delayed(const Duration(seconds: 1), () {
                _showPaymentDeadlineDialog();
              });
            }
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 40,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Text(
                            'Selesaikan pembayaran dalam',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  MediaQuery.of(context).size.width / 22.5,
                            ),
                          ),
                          Text(
                            calculateRemainingTime(snapshot.data!)
                                .toString()
                                .split('.')[0],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width / 22.5,
                              color: const Color.fromRGBO(196, 13, 15, 1),
                            ),
                          ),
                          Text(
                            'Batas Akhir Pembayaran',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.width / 27.5,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE, d MMMM yyyy HH:mm', 'id')
                                .format(snapshot.data!),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width / 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('tickets')
                            .doc(widget.code)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Cara pembayaran\n",
                                          style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  20,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              "Pastikan pembayaran Anda sudah BERHASIL dan UNGGAH BUKTI untuk mempercepat proses verifikasi.",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                25,
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'TRANSFER ${snapshot.data!.data()!['viaPayment']}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: snapshot.data!
                                                                    .data()![
                                                                'paymentMethod'] ==
                                                            'TRANSFER BANK'
                                                        ? 'Nomor Rekening\n'
                                                        : 'Nomor ${snapshot.data!.data()!['viaPayment']}\n',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        '${snapshot.data!.data()!['paymentCode']}\n',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              24,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: snapshot.data!
                                                        .data()!['anPayment'],
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade800,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(
                                                    text: snapshot.data!
                                                        .data()!['paymentCode'],
                                                  ),
                                                );
                                                // ignore: use_build_context_synchronously
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      snapshot.data!.data()![
                                                                  'paymentMethod'] ==
                                                              'TRANSFER BANK'
                                                          ? 'Nomor rekening berhasil disalin!.'
                                                          : 'Nomor ${snapshot.data!.data()!['viaPayment']} berhasil disalin!.',
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  FluentIcons.copy_24_regular),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "Detail pesanan",
                                                  style: GoogleFonts.poppins(
                                                    textStyle: TextStyle(
                                                      color: Colors.black,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            snapshot.data!.id,
                                            style: TextStyle(
                                                color: const Color.fromRGBO(
                                                    196, 13, 15, 1),
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    20),
                                          )
                                        ],
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat(
                                                      'dd MMMM yyyy • HH:mm WIB',
                                                      'id')
                                                  .format(
                                                DateFormat('yyyy-MM-dd HH.mm',
                                                        'id')
                                                    .parse(
                                                  snapshot.data!
                                                      .data()!['matchTime'],
                                                ),
                                              ),
                                            ),
                                            Text(
                                              snapshot.data!
                                                  .data()!['teamMatch'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    22.5,
                                              ),
                                            ),
                                            const Divider(),
                                            Column(
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
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            27.5,
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
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
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text('Total harga'),
                                                      Text(
                                                        'Rp ${double.parse(
                                                          snapshot.data!
                                                              .data()![
                                                                  'totalPrice']
                                                              .toString(),
                                                        ).toStringAsFixed(3)}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromRGBO(196, 13, 15, 1),
                                    fixedSize: Size(
                                      MediaQuery.of(context).size.width - 40,
                                      20,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return UploadProof(code: widget.code);
                                    }));
                                  },
                                  child: const Text(
                                    'UNGGAH BUKTI TRANSFER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                  ],
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
