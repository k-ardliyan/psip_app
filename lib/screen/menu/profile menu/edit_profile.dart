import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/user_model.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _EditProfileState extends State<EditProfile> {
  UserModel? user;
  String name = '';
  String number = '';
  String address = '';
  String selectedGender = '';

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
          name = value.data()!['displayName'];
          number = value.data()!['phoneNumber'];
          address = value.data()!['address'];
          selectedGender = value.data()!['gender'];
        }
        setState(() {});
      });
    }
  }

  Future<void> getData() async {
    // Get the data from Firestore
    DocumentSnapshot value = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    if (value.exists) {
      name = value['displayName'];
      number = value['phoneNumber'];
      address = value['address'];
      selectedGender = value['gender']; // Assuming 'name' field exists
    }
    setState(() {}); // Update UI with initial value
  }

  void updateUser() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'displayName': name, // Use the updated value from 'name' variable
      'phoneNumber': number,
      'address': address,
      'gender': selectedGender,
    }).whenComplete(() {
      getData(); // Refresh the initial value after update
      Get.back();
    });
    if (kDebugMode) {
      print('User data updated successfully!');
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
      body: user?.displayName == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ubah data diri",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
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
                        initialValue: name.toUpperCase(),
                        onChanged: (value) => name = value.toUpperCase(),
                        inputFormatters: [UpperCaseTextFormatter()],
                        textCapitalization: TextCapitalization.characters,
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
                        initialValue: number,
                        onChanged: (value) => number = value,
                        keyboardType: TextInputType.phone,
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
                        initialValue: address,
                        onChanged: (value) => address = value,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Jenis kelamin",
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: ListTile(
                            horizontalTitleGap: 0,
                            leading: Radio(
                              fillColor: const WidgetStatePropertyAll(
                                Color.fromRGBO(196, 13, 15, 1),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: 'Laki-laki',
                              groupValue: selectedGender,
                              onChanged: (value) =>
                                  setState(() => selectedGender = value!),
                            ),
                            title: const Text(
                              'Laki-laki',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            horizontalTitleGap: 0,
                            leading: Radio(
                              fillColor: const WidgetStatePropertyAll(
                                Color.fromRGBO(196, 13, 15, 1),
                              ),
                              value: 'Perempuan',
                              groupValue: selectedGender,
                              onChanged: (value) =>
                                  setState(() => selectedGender = value!),
                            ),
                            title: const Text(
                              'Perempuan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        updateUser();
                      },
                      child: Text(
                        "Konfirmasi",
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
