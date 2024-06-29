import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/screen/menu/profile%20menu/edit_profile.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key, required this.code});
  final String code;

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  final nameAccount = TextEditingController();
  final numberAccount = TextEditingController();

  Future<void> setPayment(method, number, viaPayment, an) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(widget.code)
        .update({
      'paymentMethod': method,
      'paymentCode': number,
      'paymentStatus': 'menunggu',
      'ticketStatus': 'pending',
      'viaPayment': viaPayment,
      'anPayment': an,
      'numberAccount': numberAccount.text,
      'nameAccount': nameAccount.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          const SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
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
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
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
                                          backgroundColor: Colors.white,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: const EdgeInsets.only(
                                                top: 25,
                                                left: 20,
                                                right: 20,
                                                bottom: 25,
                                              ),
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    snapshot.data!.docs[index]
                                                        ['paymentMethod'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
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
                                                    decoration: InputDecoration(
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
                                                              color:
                                                                  Colors.grey),
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
                                                    controller: numberAccount,
                                                    onSaved: (newValue) {
                                                      numberAccount.text =
                                                          newValue!;
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter()
                                                    ],
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .characters,
                                                    decoration: InputDecoration(
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
                                                              color:
                                                                  Colors.grey),
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
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        20,
                                                      ),
                                                      disabledBackgroundColor:
                                                          const Color.fromRGBO(
                                                        196,
                                                        13,
                                                        15,
                                                        0.5,
                                                      ),
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                        196,
                                                        13,
                                                        15,
                                                        1,
                                                      ),
                                                    ),
                                                    onPressed: nameAccount
                                                                .text.isEmpty &&
                                                            numberAccount
                                                                .text.isEmpty
                                                        ? null
                                                        : () {},
                                                    child: const Text(
                                                      'SIMPAN',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                        textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
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
                                          backgroundColor: Colors.white,
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              padding: const EdgeInsets.only(
                                                top: 25,
                                                left: 20,
                                                right: 20,
                                                bottom: 25,
                                              ),
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    snapshot.data!.docs[index]
                                                        ['paymentMethod'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          MediaQuery.of(context)
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
                                                    decoration: InputDecoration(
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
                                                              color:
                                                                  Colors.grey),
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
                                                    controller: numberAccount,
                                                    onSaved: (newValue) {
                                                      numberAccount.text =
                                                          newValue!;
                                                    },
                                                    keyboardType:
                                                        TextInputType.number,
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter()
                                                    ],
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .characters,
                                                    decoration: InputDecoration(
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
                                                              color:
                                                                  Colors.grey),
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
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                        20,
                                                      ),
                                                      disabledBackgroundColor:
                                                          const Color.fromRGBO(
                                                        196,
                                                        13,
                                                        15,
                                                        0.5,
                                                      ),
                                                      backgroundColor:
                                                          const Color.fromRGBO(
                                                        196,
                                                        13,
                                                        15,
                                                        1,
                                                      ),
                                                    ),
                                                    onPressed: nameAccount
                                                                .text.isEmpty &&
                                                            numberAccount
                                                                .text.isEmpty
                                                        ? null
                                                        : () {},
                                                    child: const Text(
                                                      'SIMPAN',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
