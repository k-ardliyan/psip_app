import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/screen/menu/profile%20menu/edit_profile.dart';
import 'package:psip_app/screen/menu/ticket%20menu/ticket_payment.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key, required this.code});
  final String code;

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int quota = 0;
  int quantity = 0;
  String teamMatch = '';
  String tribun = '';

  Future<void> plusQuota() async {
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
        quota = quota + quantity;
      });
      await FirebaseFirestore.instance
          .collection('match')
          .doc(teamMatch)
          .collection('tribun')
          .doc(tribun)
          .update({'quota': quota}).whenComplete(() {
        Get.back();
      });
    });
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

  final nameAccount = TextEditingController();
  final numberAccount = TextEditingController();
  final countDownPayment = DateTime.now().add(
    const Duration(minutes: 30),
  );

  bool loadSet = false;

  Future<void> setPayment(method, number, viaPayment, an) async {
    final timestamp = Timestamp.fromDate(countDownPayment);
    setState(() {
      loadSet = !loadSet;
    });
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.code)
        .update({
      'countdownPayment': timestamp,
      'paymentMethod': method,
      'paymentCode': number,
      'proofUrl': null,
      'paymentStatus': 'menunggu',
      'ticketStatus': 'pending',
      'viaPayment': viaPayment,
      'anPayment': an,
      'numberAccount': numberAccount.text,
      'nameAccount': nameAccount.text,
    }).whenComplete(() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return TicketPayment(code: widget.code);
        }),
        (Route<dynamic> route) => route.isFirst,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              plusQuota();
            },
            child: const SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ];
      },
      body: Scaffold(
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
                        text: "Pilih metode pembayaran",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width / 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('payments')
                        .where('paymentMethod', isEqualTo: 'TRANSFER BANK')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Bayar dengan TRANSFER BANK",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              21,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey.shade600),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          backgroundColor: Colors.white,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                    vertical: 25,
                                                  ),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      1.75,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'TRANSFER ${snapshot.data!.docs[index].id}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              18,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller: nameAccount,
                                                        onSaved: (newValue) {
                                                          nameAccount.text =
                                                              newValue!;
                                                        },
                                                        keyboardType:
                                                            TextInputType.name,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter()
                                                        ],
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .characters,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          label: Text(
                                                            "Nama Pemilik Rekening",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22.5,
                                                            ),
                                                          ),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                          hintText:
                                                              'Contoh: RIFFAT IMAN HIRZI',
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .always,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            numberAccount,
                                                        onSaved: (newValue) {
                                                          numberAccount.text =
                                                              newValue!;
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter()
                                                        ],
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .characters,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          label: Text(
                                                            "No. Rekening",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22.5,
                                                            ),
                                                          ),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                          hintText:
                                                              'Contoh: 123456789',
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .always,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          fixedSize: Size(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            20,
                                                          ),
                                                          disabledBackgroundColor:
                                                              const Color
                                                                  .fromRGBO(196,
                                                                  13, 15, 0.5),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromRGBO(196,
                                                                  13, 15, 1),
                                                        ),
                                                        onPressed: !loadSet &&
                                                                nameAccount.text
                                                                    .isNotEmpty &&
                                                                numberAccount
                                                                    .text
                                                                    .isNotEmpty
                                                            ? () {
                                                                setPayment(
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'paymentMethod'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'numberPayment'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'namePayment'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        ['an']);
                                                              }
                                                            : null,
                                                        child: const Text(
                                                          'SIMPAN',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          fixedSize: Size(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            20,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          nameAccount.clear();
                                                          numberAccount.clear();
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                          'PILIH METODE LAIN',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    horizontalTitleGap: 10,
                                    dense: true,
                                    title: Text(
                                      snapshot.data!.docs[index].id,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(
                                        FluentIcons.chevron_right_48_filled),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('payments')
                        .where('paymentMethod', isEqualTo: 'E-WALLET')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Bayar dengan E-WALLET",
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              21,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey.shade600),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          isScrollControlled: true,
                                          isDismissible: false,
                                          backgroundColor: Colors.white,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                    vertical: 25,
                                                  ),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      1.75,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'TRANSFER ${snapshot.data!.docs[index].id}',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              18,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      TextFormField(
                                                        controller: nameAccount,
                                                        onSaved: (newValue) {
                                                          nameAccount.text =
                                                              newValue!;
                                                        },
                                                        keyboardType:
                                                            TextInputType.name,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter()
                                                        ],
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .characters,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          label: Text(
                                                            "Nama Pemilik Rekening",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22.5,
                                                            ),
                                                          ),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                          hintText:
                                                              'Contoh: RIFFAT IMAN HIRZI',
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .always,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      TextFormField(
                                                        controller:
                                                            numberAccount,
                                                        onSaved: (newValue) {
                                                          numberAccount.text =
                                                              newValue!;
                                                        },
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          UpperCaseTextFormatter()
                                                        ],
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .characters,
                                                        decoration:
                                                            InputDecoration(
                                                          isDense: false,
                                                          label: Text(
                                                            "No. Rekening",
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  22.5,
                                                            ),
                                                          ),
                                                          hintStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                          hintText:
                                                              'Contoh: 123456789',
                                                          floatingLabelBehavior:
                                                              FloatingLabelBehavior
                                                                  .always,
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          fixedSize: Size(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            20,
                                                          ),
                                                          disabledBackgroundColor:
                                                              const Color
                                                                  .fromRGBO(
                                                            196,
                                                            13,
                                                            15,
                                                            0.5,
                                                          ),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromRGBO(
                                                            196,
                                                            13,
                                                            15,
                                                            1,
                                                          ),
                                                        ),
                                                        onPressed: !loadSet &&
                                                                nameAccount.text
                                                                    .isNotEmpty &&
                                                                numberAccount
                                                                    .text
                                                                    .isNotEmpty
                                                            ? () {
                                                                setPayment(
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'paymentMethod'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'numberPayment'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'namePayment'],
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        ['an']);
                                                              }
                                                            : null,
                                                        child: const Text(
                                                          'SIMPAN',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          fixedSize: Size(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            20,
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          nameAccount.clear();
                                                          numberAccount.clear();
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                          'PILIH METODE LAIN',
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    horizontalTitleGap: 10,
                                    dense: true,
                                    title: Text(
                                      snapshot.data!.docs[index].id,
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    trailing: const Icon(
                                        FluentIcons.chevron_right_48_filled),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
