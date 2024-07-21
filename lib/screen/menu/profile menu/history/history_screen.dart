import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/profile%20menu/history/detail_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Riwayat pesanan",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width / 16.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('uid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where(
                      'matchTime',
                      isLessThan: DateFormat('yyyy-MM-dd HH.mm').format(
                        DateTime.now().subtract(
                          const Duration(hours: 4),
                        ),
                      ),
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(),
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return DetailHistory(
                                          code: snapshot.data!.docs[index].id
                                              .toString());
                                    }),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                      ),
                                      child: Text(
                                        DateFormat('dd MMMM yyyy', 'id').format(
                                          DateTime.parse(
                                            snapshot.data!.docs[index]
                                                ['orderDate'],
                                          ),
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              27.5,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Kode Pesanan ',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade800,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: snapshot.data!
                                                            .docs[index].id,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade900,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    snapshot
                                                        .data!
                                                        .docs[index]
                                                            ['paymentStatus']
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors
                                                          .greenAccent.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 10,
                                            ),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            child: Column(
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    snapshot.data!
                                                        .docs[index]['event']
                                                        .toString()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.grey.shade900,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              22.5,
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Text(
                                                    snapshot.data!.docs[index]
                                                        ['tribun'],
                                                    style: const TextStyle(
                                                      color: Color.fromRGBO(
                                                          196, 13, 15, 1),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    snapshot.data!.docs[index]
                                                        ['teamMatch'],
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  minTileHeight: 0,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: const Text(
                                                    'Total Harga',
                                                  ),
                                                  trailing: Text(
                                                    'Rp ${double.parse(
                                                      snapshot
                                                          .data!
                                                          .docs[index]
                                                              ['totalPrice']
                                                          .toString(),
                                                    ).toStringAsFixed(3)}',
                                                    style: TextStyle(
                                                      color:
                                                          const Color.fromRGBO(
                                                              196, 13, 15, 1),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              27,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                })
          ],
        ),
      ),
    );
  }
}
