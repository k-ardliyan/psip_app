import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:psip_app/screen/menu/ticket_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ETICKET extends StatefulWidget {
  const ETICKET({super.key, required this.data});
  final QueryDocumentSnapshot data;

  @override
  State<ETICKET> createState() => _ETICKETState();
}

class _ETICKETState extends State<ETICKET> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('tickets')
              .doc(widget.data.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.stadium_rounded),
                          title: Text(
                            snapshot.data!
                                .data()!['stadium']
                                .toString()
                                .toUpperCase(),
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Kode pesanan : ',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: snapshot.data!.id,
                                style: const TextStyle(
                                  color: Color.fromRGBO(196, 13, 15, 1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            snapshot.data!.data()!['event'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            DateFormat('EEEE, dd MMMM yyyy • HH:mm WIB', 'id')
                                .format(
                              DateFormat('yyyy-MM-dd HH.mm', 'id').parse(
                                snapshot.data!.data()!['matchTime'],
                              ),
                            ),
                            style: const TextStyle(
                              color: Color.fromRGBO(196, 13, 15, 1),
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 40,
                              width: 20,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(196, 13, 15, 1),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(50),
                                ),
                              ),
                            ),
                            Expanded(
                              child: CustomPaint(
                                painter: const DottedLinePainter(
                                    color: Colors.grey, strokeWidth: 2.0),
                                size: Size(MediaQuery.of(context).size.width,
                                    1.0), // Adjust height to desired thickness
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 20,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(196, 13, 15, 1),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(50),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pemesan',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  snapshot.data!['orderName'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Nomor HP',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  snapshot.data!['orderPhone'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            snapshot.data!['tribun'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(context).size.width / 25,
                            ),
                          ),
                          trailing: Text(
                            '${snapshot.data!['quantity'].toString()}  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: MediaQuery.of(context).size.width / 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Pindai kode ini di Gerbang',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      QrImageView(
                        data: widget.data.id,
                        size: MediaQuery.of(context).size.width / 2,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        embeddedImageEmitsError: true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'Dipesan : ${DateFormat('d MMMM yyyy HH:mm', 'id').format(
                                DateFormat('yyyy-MM-dd HH:mm', 'id').parse(
                                  snapshot.data!['orderDate'],
                                ),
                              ).toString()}'),
                      const SizedBox(
                        height: 10,
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
