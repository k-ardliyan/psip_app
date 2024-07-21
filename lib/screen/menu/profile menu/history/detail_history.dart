import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DetailHistory extends StatefulWidget {
  const DetailHistory({super.key, this.code});
  final String? code;

  @override
  State<DetailHistory> createState() => _DetailHistoryState();
}

class _DetailHistoryState extends State<DetailHistory> {
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
              .doc(widget.code)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/Logo_PSIP_Pemalang.png',
                              height: MediaQuery.of(context).size.width / 7.5,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 7.5,
                              child: VerticalDivider(
                                width: 25,
                                color: Colors.grey.shade900,
                                thickness: 2,
                              ),
                            ),
                            Text(
                              'LASKAR \nBENOWO',
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 22.5,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Kode Pemesanan'),
                            Text(
                              snapshot.data!.id,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.shade400,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                snapshot.data!.data()!['event'],
                                style: const TextStyle(
                                  color: Color.fromRGBO(196, 13, 15, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                DateFormat(
                                        'EEEE, dd MMMM yyyy • HH:mm WIB', 'id')
                                    .format(
                                  DateFormat('yyyy-MM-dd HH.mm', 'id').parse(
                                    snapshot.data!.data()!['matchTime'],
                                  ),
                                ),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('logo')
                                        .doc(
                                          snapshot.data!.data()!['home'],
                                        )
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
                                const Text(
                                  'VS',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    height: 0.9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('logo')
                                        .doc(
                                          snapshot.data!.data()!['away'],
                                        )
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
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        snapshot.data!['orderName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        snapshot.data!['orderPhone'],
                      ),
                      trailing: Text(
                        snapshot.data!['tribun'],
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          color: const Color.fromRGBO(196, 13, 15, 1),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 0,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Total'),
                      subtitle: Text('(${snapshot.data!['quantity']}x) Tiket'),
                      trailing: Text(
                        'Rp ${double.parse(
                          snapshot.data!['totalPrice'].toString(),
                        ).toStringAsFixed(3)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width / 25,
                        ),
                      ),
                    ),
                  ],
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
