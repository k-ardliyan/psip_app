import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadProof extends StatefulWidget {
  const UploadProof({super.key, required this.code});
  final String code;

  @override
  State<UploadProof> createState() => _UploadProofState();
}

class _UploadProofState extends State<UploadProof> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  Image? pickedImage;
  File? imageFile;
  XFile? pickedFile;

  Future<void> _getImage() async {
    pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pickedImage = Image.file(fit: BoxFit.cover, File(pickedFile!.path));
        imageFile = File(pickedFile!.path);
      });
    }
  }

  Future<String?> uploadImage(image) async {
    if (pickedImage != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('images/proof/_${widget.code}.png');
        await storageRef.putFile(
          image,
          SettableMetadata(
            contentType: 'image/png',
          ),
        );
        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      } catch (error) {
        if (kDebugMode) {
          print('Error uploading image: $error');
        }
        return null;
      }
    } else {
      if (kDebugMode) {
        print('No image selected for upload');
      }
      return null;
    }
  }

  Future<void> saveImageToFirestore(String imageUrl, matchTime) async {
    final firestoreRef = FirebaseFirestore.instance.collection('tickets');
    await firestoreRef.doc(widget.code).update({
      'countdownPayment': Timestamp.fromDate(
        DateTime.parse(
          matchTime.toString().replaceAll('.', ':'),
        ),
      ),
      'proofUrl': imageUrl,
      'checkIn': false,
      'paymentStatus': 'verifikasi',
      'paymentDate': DateFormat('yyyy-MM-dd HH:mm', 'id_ID').format(
        DateTime.now().toUtc().add(
              const Duration(hours: 7),
            ),
      ),
      // Add other image metadata if needed
    });
  }

  Future<void> handleUploadImage(matchTime) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      final imageUrl = await uploadImage(imageFile);
      if (imageUrl != null) {
        await saveImageToFirestore(
            imageUrl, matchTime); // Replace 'my_image' with a desired name
        if (kDebugMode) {
          print('Image uploaded and saved successfully!');
        }
      } else {
        if (kDebugMode) {
          print('Error uploading image');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Unggah bukti transfer\n",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            16.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Unggah bukti transfer Anda. Pastikan gambar bukti transfer terlihat jelas, pastikan juga bukti transfer menampilkan :",
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
                      ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ListTile(
                              minTileHeight: 10,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.fiber_manual_record,
                                size: MediaQuery.of(context).size.width / 22,
                                color: const Color.fromRGBO(196, 13, 15, 1),
                              ),
                              title: const Text('Tanggal/Waktu Transfer'),
                            ),
                            ListTile(
                              minTileHeight: 10,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.fiber_manual_record,
                                size: MediaQuery.of(context).size.width / 22,
                                color: const Color.fromRGBO(196, 13, 15, 1),
                              ),
                              title: const Text('Status Berhasil'),
                            ),
                            ListTile(
                              minTileHeight: 10,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.fiber_manual_record,
                                size: MediaQuery.of(context).size.width / 22,
                                color: const Color.fromRGBO(196, 13, 15, 1),
                              ),
                              title: const Text('Detail Penerima'),
                            ),
                            ListTile(
                              minTileHeight: 10,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.fiber_manual_record,
                                color: const Color.fromRGBO(196, 13, 15, 1),
                                size: MediaQuery.of(context).size.width / 22,
                              ),
                              title: const Text('Jumlah Transfer'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            _getImage();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              pickedImage != null &&
                                      snapshot.data!.data()!['proofUrl'] == null
                                  ? SizedBox(
                                      height:
                                          MediaQuery.of(context).size.width /
                                              2.2,
                                      child: pickedImage!)
                                  : pickedImage == null &&
                                          snapshot.data!.data()!['proofUrl'] !=
                                              null
                                      ? SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.2,
                                          child: Image.network(snapshot.data!
                                              .data()!['proofUrl']),
                                        )
                                      : pickedImage != null &&
                                              snapshot.data!
                                                      .data()!['proofUrl'] !=
                                                  null
                                          ? SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.2,
                                              child: Image.network(snapshot
                                                  .data!
                                                  .data()!['proofUrl']),
                                            )
                                          : const Icon(Icons.image),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor:
                              const Color.fromRGBO(196, 13, 15, 0.5),
                          backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                          fixedSize: Size(
                            MediaQuery.of(context).size.width - 40,
                            20,
                          ),
                        ),
                        onPressed: pickedImage != null &&
                                snapshot.data!.data()!['proofUrl'] == null
                            ? () {
                                handleUploadImage(
                                    snapshot.data!.data()!['matchTime']);
                              }
                            : null,
                        child: Text(
                          pickedImage != null &&
                                  snapshot.data!.data()!['proofUrl'] == null
                              ? 'KIRIM BUKTI TRANSFER'
                              : 'PROSES VERIFIKASI...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
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
