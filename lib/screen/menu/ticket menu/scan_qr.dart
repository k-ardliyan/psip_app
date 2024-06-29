import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          ? QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(snapshot.data!.id),
                        Text(snapshot.data!.data()!['tribun']),
                        Text(snapshot.data!.data()!['teamMatch']),
                        Text(snapshot.data!.data()!['orderName']),
                        Text(snapshot.data!.data()!['orderEmail']),
                        Text(snapshot.data!.data()!['orderPhone']),
                        Text(snapshot.data!.data()!['orderAddress']),
                        Text('${snapshot.data!.data()!['quantity']} tiket '),
                      ],
                    ),
                  );
                }
                return QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                );
              },
            ),
    );
  }
}
