import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TicketPayment extends StatefulWidget {
  const TicketPayment({super.key, required this.code});
  final String code;

  @override
  State<TicketPayment> createState() => _TicketPaymentState();
}

class _TicketPaymentState extends State<TicketPayment> {
  final ImagePicker picker = ImagePicker();
  XFile? imageFile;

  Future<void> pickImage() async {
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery, // Or ImageSource.gallery
    );

    if (pickedImage != null) {
      setState(() {
        imageFile = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
        ];
      },
      body: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(1), // Adjust shadow color and opacity
                      blurRadius: 1,
                      spreadRadius: -0.5,
                      offset: const Offset(
                        0,
                        1.5,
                      ), // Adjust the position of the shadow
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    'Selesaikan pembayaran sebelum',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 30,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('HH:mm dd MMMM yyyy', 'id').format(
                      DateTime.now().add(
                        const Duration(hours: 1),
                      ),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width / 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('tickets')
                      .doc(widget.code)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total yang harus dibayar'),
                                Text(
                                  'Rp ${double.parse(
                                    snapshot.data!
                                        .data()!['totalPrice']
                                        .toString(),
                                  ).toStringAsFixed(3)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              // enabled: false,
                              showCursor: false,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: snapshot.data!.data()!['paymentCode'],
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                isDense: false,
                                label: const Text(
                                  "Kode Pembayaran",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                        text: snapshot.data!
                                            .data()!['paymentCode']
                                            .toString(),
                                      ),
                                    );
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kode berhasil disalin'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(FluentIcons.copy_24_regular),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('logo')
                                        .doc(snapshot.data!.data()!['home'])
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
                                      snapshot.data!.data()!['event'],
                                      style: const TextStyle(
                                        color: Color.fromRGBO(196, 13, 15, 1),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMMM yyyy', 'id').format(
                                        DateFormat('yyyy-MM-dd HH.mm', 'id')
                                            .parse(
                                          snapshot.data!.data()!['matchTime'],
                                        ),
                                      ),
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
                                      DateFormat('HH:mm WIB', 'id').format(
                                        DateFormat('yyyy-MM-dd HH.mm', 'id')
                                            .parse(
                                          snapshot.data!.data()!['matchTime'],
                                        ),
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 5,
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('logo')
                                        .doc(snapshot.data!.data()!['away'])
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
                          ],
                        ),
                      );
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
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
                  // showDialog(
                  //     context: context,
                  //     builder: (context) {
                  //       return AlertDialog(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         title: const Text(
                  //           'Bukti transfer',
                  //           style: TextStyle(fontWeight: FontWeight.w600),
                  //         ),
                  //       );
                  //     });
                },
                child: Text(
                  'UNGGAH BUKTI',
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
}
