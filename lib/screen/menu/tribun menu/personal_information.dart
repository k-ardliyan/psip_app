import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/user_model.dart';
import 'package:psip_app/model/utils.dart';
import 'package:psip_app/screen/menu/tribun%20menu/order_details.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key, required this.code});
  final String code;

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  UserModel? user;
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final address = TextEditingController();
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        if (value.exists) {
          user = UserModel.fromMap(value.data()!);
        }
        setState(() {});
      });
    }
  }

  void _toggleSwitch(bool newValue) async {
    setState(() {
      isSelected =
          newValue; // Enable "Clear Data" button only when data is visible
    });

    if (isSelected) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        if (value.exists) {
          name.text = '${value.data()!['displayName']}';
          phoneNumber.text = '${value.data()!['phoneNumber']}';
          address.text = '${value.data()!['address']}';
          email.text = '${value.data()!['email']}';
        }
        setState(() {});
      });
    } else {
      name.text = '';
      phoneNumber.text = '';
      address.text = '';
      email.text = ''; // Clear data when switch is off
    }
  }

  Future addIdentity(String n, String e, String pn, String a) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.code)
          .update({
        'orderEmail': e,
        'orderName': n,
        'orderPhone': pn,
        'orderAddress': a,
      }).whenComplete(() {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetails(code: widget.code),
            ),
            (Route<dynamic> route) => route.isFirst);
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }

      Utils.showSnackBar(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return user?.displayName == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Container(
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
                              text: "Informasi pengguna",
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return ListTile(
                                    title: Text(
                                      snapshot.data?.data()!['displayName'],
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data?.data()!['email'],
                                      style: TextStyle(
                                          color: Colors.grey.shade800),
                                    ),
                                    trailing: Switch(
                                      value: isSelected,
                                      onChanged: (newValue) {
                                        _toggleSwitch(newValue);
                                      },
                                      activeColor: Colors.green,
                                      inactiveThumbColor: Colors.grey,
                                      inactiveTrackColor: Colors.white,
                                    ),
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Text('Tambahkan sebagai pemesan'),
                          ),
                          const SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Detail pemesan",
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: name,
                        onSaved: (value) => name.text = value!,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Silahkan masukkan nama lengkap Anda");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: false,
                          label: Text(
                            "Nama lengkap",
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          hintText: 'Masukkan nama lengkap Anda',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: email,
                        onSaved: (value) => email.text = value!,
                        keyboardType: TextInputType.emailAddress,
                        validator: (email) {
                          if (email!.isEmpty) {
                            return ("Silahkan Masukkan Email Anda");
                          }
                          // reg expression for email validation
                          if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                              .hasMatch(email)) {
                            return ("Format email salah");
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: false,
                          label: Text(
                            "Email",
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          hintText: 'Masukkan email Anda',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: phoneNumber,
                        onSaved: (value) => phoneNumber.text = value!,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          RegExp regex =
                              RegExp(r'^(\+62|0)([8]\d{2,3})(\d{5,8})$');
                          if (value!.isEmpty) {
                            return ("Silahkan tulis nomor telepon Anda");
                          }
                          if (!regex.hasMatch(value)) {
                            return ("Nomor telepon Anda tidak valid!");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: false,
                          label: Text(
                            "Nomor telepon",
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          hintText: 'Masukkan nomor telepon Anda',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: address,
                        onSaved: (value) => address.text = value!,
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return ("Silahkan masukkan alamat Anda");
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          isDense: false,
                          label: Text(
                            "Alamat",
                            style: TextStyle(color: Colors.grey.shade800),
                          ),
                          hintText: 'Masukkan alamat Anda',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
                        disabledBackgroundColor:
                            const Color.fromRGBO(196, 13, 15, 0.5),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width,
                          45,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                title: const Text('Apakah data sudah sesuai?'),
                                content: const Text(
                                    'Pastikan data yang Anda masukan telah sesuai, Anda tidak dapat mengubah detail pesanan setelah melanjutkan ke halaman pembayaran'),
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
                                    onPressed: () {
                                      addIdentity(
                                        name.text,
                                        email.text,
                                        phoneNumber.text,
                                        address.text,
                                      );
                                    },
                                    child: Text(
                                      'YA, LANJUTKAN',
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
                      child: Text(
                        "Konfirmasi",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
