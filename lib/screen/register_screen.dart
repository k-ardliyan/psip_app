// ignore_for_file: equal_elements_in_set

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/model/user_model.dart';
import 'package:psip_app/model/utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onClickedSignin});

  final VoidCallback onClickedSignin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();

  String selectedGender = '';

  bool isVisible = true;
  bool isVisible2 = true;
  void toggleVisible() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  void toggleVisible2() {
    setState(() {
      isVisible2 = !isVisible2;
    });
  }

  bool isNext = true;
  void toggleNext() {
    setState(() {
      isNext = !isNext;
    });
  }

  final divider = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: const Divider(
            color: Colors.white70,
          ),
        ),
      ),
      const Text(
        "Atau",
        style: TextStyle(color: Colors.white),
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: const Divider(
            color: Colors.white70,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(196, 13, 15, 1),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          margin: const EdgeInsets.only(bottom: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    top: 40,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(196, 13, 15, 1),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 2.5,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      )
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/Logo_PSIP_Pemalang.png',
                          height: MediaQuery.of(context).size.width / 2.75,
                        ),
                        const SizedBox(
                          height: 120,
                          child: VerticalDivider(
                            width: 25,
                            color: Colors.white,
                            thickness: 2,
                          ),
                        ),
                        Text(
                          'LASKAR \nBENOWO',
                          softWrap: true,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  controller: displayNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Silahkan masukkan nama lengkap Anda");
                    }

                    return null;
                  },
                  onSaved: (value) {
                    displayNameController.text = value!;
                  },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Nama lengkap',
                    hintText: 'Masukkan nama lengkap anda',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    prefixIcon: Icon(Icons.account_circle_rounded),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                  onSaved: (email) {
                    emailController.text = email!;
                  },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Email',
                    hintText: 'Masukkan email anda',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    prefixIcon: Icon(Icons.mail),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: isVisible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Silahkan Masukkan Kata Sandi Anda");
                    } else if (!RegExp(r'^.{8,}$').hasMatch(value)) {
                      return ("Kata sandi harus paling tidak 8 karakter");
                    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Kata sandi harus mengandung setidaknya satu huruf kecil';
                    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Kata sandi harus mengandung setidaknya satu huruf kapital';
                    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Kata sandi harus mengandung setidaknya satu angka';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    passwordController.text = value!;
                  },
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Kata sandi',
                    hintText: 'Masukkan kata sandi anda',
                    prefixIcon: const Icon(Icons.vpn_key),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    suffixIcon: IconButton(
                      onPressed: () {
                        toggleVisible();
                      },
                      icon: Icon(
                          isVisible ? Icons.visibility_off : Icons.visibility),
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  obscureText: isVisible2,
                  keyboardType: TextInputType.visiblePassword,
                  controller: confirmPasswordController,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ('Silahkan ulangi kata sandi Anda');
                    }
                    if (confirmPasswordController.text !=
                        passwordController.text) {
                      return "Kata Sandi tidak sama";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    confirmPasswordController.text = value!;
                  },
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Konfirmasi kata sandi',
                    hintText: 'Masukkan konfirmasi kata sandi anda',
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
                    border: const OutlineInputBorder(),
                    filled: true,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Jenis kelamin",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: ListTile(
                              horizontalTitleGap: 0,
                              leading: Radio(
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.blue),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              horizontalTitleGap: 0,
                              leading: Radio(
                                fillColor:
                                    const WidgetStatePropertyAll(Colors.blue),
                                value: 'Perempuan',
                                groupValue: selectedGender,
                                onChanged: (value) =>
                                    setState(() => selectedGender = value!),
                              ),
                              title: const Text(
                                'Perempuan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  controller: phoneNumberController,
                  onSaved: (value) {
                    phoneNumberController.text = value!;
                  },
                  validator: (value) {
                    RegExp regex = RegExp(r'^(\+62|0)([8]\d{2,3})(\d{5,8})$');
                    if (value!.isEmpty) {
                      return ("Silahkan tulis nomor telepon Anda");
                    }
                    if (!regex.hasMatch(value)) {
                      return ("Nomor telepon Anda tidak valid!");
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Nomor Telepon',
                    hintText: 'Masukkan nomor telepon Anda',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    prefixIcon: Icon(Icons.smartphone),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.done,
                  controller: addressController,
                  onSaved: (value) {
                    addressController.text = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ("Silahkan masukkan alamat Anda");
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    errorStyle: TextStyle(color: Colors.yellow),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Alamat',
                    hintText: 'Masukkan alamat Anda',
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.blue,
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      45,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () async {
                    signUp(emailController.text, passwordController.text);
                  },
                  child: Text(
                    "Daftar",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Sudah memiliki akun? ',
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            widget.onClickedSignin();
                          },
                        text: 'Masuk',
                        style: const TextStyle(
                          color: Colors.lightBlue,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future signUp(String email, String password) async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        postDetailsToFirestore();
      }).whenComplete(() {
        Get.offAllNamed('/');
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

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sending these values

    UserModel userModel = UserModel();

    userModel.email = FirebaseAuth.instance.currentUser!.email;
    userModel.uid = FirebaseAuth.instance.currentUser!.uid;
    userModel.address = addressController.text;
    userModel.displayName = displayNameController.text;
    userModel.gender = selectedGender;
    userModel.phoneNumber = phoneNumberController.text;
    userModel.photoURL = FirebaseAuth.instance.currentUser!.photoURL;
    userModel.role = 'User';

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(
          userModel.toMap(),
        );

    GlobalKey<NavigatorState>()
        .currentState!
        .popUntil((route) => route.isFirst);
  }
}
