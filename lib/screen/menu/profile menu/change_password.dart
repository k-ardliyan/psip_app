import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psip_app/main.dart';
import 'package:psip_app/model/utils.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    // **Key change: Dispose controllers in dispose() method**
    passwordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  bool isVisible = true;
  void toggleVisible() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  bool isVisible2 = true;
  void toggleVisible2() {
    setState(() {
      isVisible2 = !isVisible2;
    });
  }

  bool isVisible3 = true;
  void toggleVisible3() {
    setState(() {
      isVisible3 = !isVisible3;
    });
  }

  Future changePassword(email, password, newPassword) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    var credential =
        EmailAuthProvider.credential(email: email, password: password);

    try {
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential)
          .then(
        (_) {
          FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
        },
      ).whenComplete(() {
        Utils.showSnackBar('Kata sandi Anda berhasil di ubah');
        Get.offAllNamed("/");
        Provider.of<GoogleSignInProvider>(context, listen: false).logout();
      });
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Utils.showSnackBar(e.message);
    }

    GlobalKey<NavigatorState>().currentState!.popUntil(
      (route) {
        return route.isFirst;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                          text: "Ubah kata sandi\n",
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
                              "Jangan bagikan kata sandi kepada siapapun\ndemi keamanan data Anda.Kata sandi Anda harus paling tidak 8 karakter.",
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
                const Divider(
                  height: 40,
                  thickness: 2,
                ),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: isVisible2,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    RegExp regex = RegExp(r'^.{8,}$');
                    if (value!.isEmpty) {
                      return ("Masukkan kata sandi baru Anda");
                    }
                    if (!regex.hasMatch(value)) {
                      return ("Kata sandi harus paling tidak 8 karakter dan sulit ditebak orang lain");
                    }
                    return null;
                  },
                  onSaved: (value) {
                    newPasswordController.text = value!;
                  },
                  decoration: InputDecoration(
                    errorStyle:
                        const TextStyle(color: Color.fromRGBO(196, 13, 15, 1)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Kata sandi baru',
                    hintText: 'Masukkan kata sandi baru Anda',
                    prefixIcon: const Icon(Icons.vpn_key),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    suffixIcon: IconButton(
                      onPressed: () {
                        toggleVisible2();
                      },
                      icon: Icon(
                          isVisible2 ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: isVisible3,
                  controller: confirmNewPasswordController,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.go,
                  validator: (value) {
                    if (confirmNewPasswordController.text !=
                        newPasswordController.text) {
                      return "Kata sandi baru tidak cocok";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    confirmNewPasswordController.text = value!;
                  },
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(
                      color: Color.fromRGBO(196, 13, 15, 1),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Ulangi kata sandi baru',
                    hintText: 'Masukkan ulang kata sandi baru Anda',
                    prefixIcon: const Icon(Icons.vpn_key),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    suffixIcon: IconButton(
                      onPressed: () {
                        toggleVisible3();
                      },
                      icon: Icon(
                          isVisible3 ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      45,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    changePassword(FirebaseAuth.instance.currentUser!.email,
                        passwordController.text, newPasswordController.text);
                  },
                  child: Text(
                    "Ubah kata sandi",
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
      ),
    );
  }
}
