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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.code)
            .snapshots(),
        builder: (context, snapshot) {
          quantity = snapshot.data!['quantity'];

          if (snapshot.hasData) {
            return PopScope(
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
                                  .collection('match')
                                  .doc(snapshot.data!['teamMatch'])
                                  .collection('tribun')
                                  .doc(snapshot.data!['tribun'])
                                  .get()
                                  .then((value) async {
                                quota = value.data()!['quota'];
                                setState(() {
                                  quota = quota + quantity;
                                });
                                await FirebaseFirestore.instance
                                    .collection('match')
                                    .doc(snapshot.data!['teamMatch'])
                                    .collection('tribun')
                                    .doc(snapshot.data!['tribun'])
                                    .update({
                                  'quota': quota,
                                });
                              }).whenComplete(() {
                                FirebaseFirestore.instance
                                    .collection('tickets')
                                    .doc(snapshot.data!.id)
                                    .delete()
                                    .then((_) {
                                  Get.offAllNamed("/");
                                });
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
                                DateFormat('yyyy-MM-dd HH.mm', 'id').parse(
                                  snapshot.data!.data()!['matchTime'],
                                ),
                              ),
                            ),
                            Text(
                              snapshot.data!.data()!['teamMatch'],
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize:
                                    MediaQuery.of(context).size.width / 22.5,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!
                                        .data()!['orderName']
                                        .toString()
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
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
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                        height: 20,
                      ),
                      ElevatedButton(
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PaymentMethod(code: widget.code);
                              },
                            ),
                          );
                        },
                        child: Text(
                          'BAYAR',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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
