import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psip_app/main.dart';
import 'package:psip_app/model/utils.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({super.key});

  @override
  State<DeleteUser> createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  bool isVisible = true;
  void toggleVisible() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  Future deleteUser(email, password) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    var credential =
        EmailAuthProvider.credential(email: email, password: password);

    try {
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential)
          .then((_) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .delete()
            .whenComplete(() {
          FirebaseAuth.instance.currentUser!.delete();
          Utils.showSnackBar('Akun Anda dihapus!');
          Get.offAllNamed("/");
          Provider.of<GoogleSignInProvider>(context, listen: false).logout();
        });
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Utils.showSnackBar('Kata sandi Anda salah!!');
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
      body: Container(
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
                        text: "Hapus akun\n",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const TextSpan(
                        text:
                            "Akan kehilangan akses ke pengalaman Anda menggunakan aplikasi. Ini akan menghapus akun atau menonaktifkan akun Anda. Masukkan kata sandi Anda untuk konfirmasi hapus akun.",
                        style: TextStyle(
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
              TextFormField(
                controller: passwordController,
                obscureText: isVisible,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.go,
                validator: (value) {
                  if (value!.isEmpty) {
                    return ("Masukkan kata sandi Anda");
                  }
                  return null;
                },
                onSaved: (value) {
                  passwordController.text = value!;
                },
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: 'Kata sandi saat ini',
                  hintText: 'Masukkan kata sandi anda saat ini',
                  prefixIcon: const Icon(Icons.vpn_key),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixIcon: IconButton(
                    onPressed: () {
                      toggleVisible();
                    },
                    icon: Icon(
                        isVisible ? Icons.visibility_off : Icons.visibility),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: GestureDetector(
                  child: const Text(
                    "Lupa kata sandi?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(196, 13, 15, 1),
                    ),
                  ),
                  onTap: () {
                    Get.toNamed('/forgot-password');
                  },
                ),
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
                  deleteUser(FirebaseAuth.instance.currentUser!.email,
                      passwordController.text);
                },
                child: Text(
                  "Konfirmasi hapus akun",
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
  }
}
