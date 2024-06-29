import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/user_model.dart';

class ProfileInformation extends StatefulWidget {
  const ProfileInformation({super.key});

  @override
  State<ProfileInformation> createState() => _ProfileInformationState();
}

class _ProfileInformationState extends State<ProfileInformation> {
  UserModel? user;

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

  Stream<DocumentSnapshot> getDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: getDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
            ),
            body: snapshot.data!['displayName'] == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Informasi data diri\n",
                                    style: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: user?.phoneNumber == '' ||
                                            user?.address == '' ||
                                            user?.gender == ''
                                        ? "Informasi data diri Anda belum lengkap, Silahkan lengkapi data diri Anda."
                                        : "Informasi data diri Anda sudah lengkap, tekan ubah jika ingin mengubah data diri Anda.",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              // enabled: false,
                              showCursor: false,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText:
                                    "${FirebaseAuth.instance.currentUser!.uid.substring(0, 24).toUpperCase()}.....",
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                isDense: false,
                                label: Text(
                                  "ID pelanggan",
                                  style: TextStyle(color: Colors.grey.shade800),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    await Clipboard.setData(
                                      ClipboardData(
                                          text: FirebaseAuth
                                              .instance.currentUser!.uid),
                                    );
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('ID berhasil disalin!'),
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
                          ),
                          const SizedBox(
                            height: 20,
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
                              initialValue:
                                  FirebaseAuth.instance.currentUser!.email,
                              enabled: false,
                              decoration: InputDecoration(
                                isDense: false,
                                label: Text(
                                  "Email",
                                  style: TextStyle(color: Colors.grey.shade800),
                                ),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                disabledBorder: InputBorder.none,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          hintText: snapshot
                                                  .data!['displayName']
                                                  .toUpperCase() ??
                                              '******',
                                          hintStyle: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          label: Text(
                                            "Nama lengkap",
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.toNamed('/edit-profile');
                                      },
                                      child: const Text(
                                        "UBAH",
                                        style: TextStyle(
                                          color: Color.fromRGBO(196, 13, 15, 1),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText:
                                        snapshot.data!['phoneNumber'] == ''
                                            ? '-'
                                            : snapshot.data!['phoneNumber'],
                                    hintStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    label: Text(
                                      "Nomor telepon",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                                TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: snapshot.data!['address'] == ''
                                        ? '-'
                                        : snapshot.data!['address'],
                                    hintStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    label: Text(
                                      "Alamat",
                                      style: TextStyle(
                                          color: Colors.grey.shade800),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                                TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    hintText: snapshot.data!['gender'] == ''
                                        ? '-'
                                        : snapshot.data!['gender'],
                                    hintStyle: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    label: Text(
                                      "Jenis kelamin",
                                      style: TextStyle(
                                          color: Colors.grey.shade800),
                                    ),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    disabledBorder: InputBorder.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  const Color.fromRGBO(196, 13, 15, 1),
                              fixedSize: Size(
                                MediaQuery.of(context).size.width,
                                45,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Get.toNamed('/delete-user');
                            },
                            child: Text(
                              "Hapus akun",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
