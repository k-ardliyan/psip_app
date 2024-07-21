import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result; // To store scan results
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: result?.code == null
          ? Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent.withOpacity(0),
                elevation: 0,
              ),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  QRView(
                    overlay: QrScannerOverlayShape(
                      overlayColor: const Color.fromRGBO(0, 0, 0, 85),
                      borderColor: Colors.white,
                      borderWidth: 10,
                      borderRadius: 10,
                    ),
                    formatsAllowed: const [
                      BarcodeFormat.qrcode,
                    ],
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height / 6.75,
                    child: Text(
                      'Pindai kode QR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 18,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .doc(result?.code)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
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
                        ListTile(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        const Divider(
                          height: 20,
                        ),
                        Row(
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
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    snapshot.data!['paymentStatus']
                                        .toString()
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ListTile(
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
                        Text(
                          'CHECK IN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width / 20,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        RawMaterialButton(
                          shape: const CircleBorder(),
                          fillColor: snapshot.data!['checkIn'] == false
                              ? Colors.green
                              : Colors.redAccent,
                          padding: const EdgeInsets.all(12),
                          onPressed: snapshot.data!['checkIn'] == false
                              ? () async {
                                  await FirebaseFirestore.instance
                                      .collection('tickets')
                                      .doc(snapshot.data!.id)
                                      .update({
                                    'checkIn': true,
                                  }).then(
                                    (onValue) {
                                      setState(() {
                                        result = null;
                                      });
                                    },
                                  );
                                }
                              : () async {
                                  await FirebaseFirestore.instance
                                      .collection('tickets')
                                      .doc(snapshot.data!.id)
                                      .update({
                                    'checkIn': false,
                                  }).then(
                                    (onValue) {
                                      setState(() {
                                        result = null;
                                      });
                                    },
                                  );
                                },
                          child: Icon(
                            snapshot.data!['checkIn'] == false
                                ? FontAwesomeIcons.check
                                : Icons.close,
                            size: MediaQuery.of(context).size.width / 5,
                            color: Colors.white,
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
}
