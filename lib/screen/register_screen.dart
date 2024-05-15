// ignore_for_file: equal_elements_in_set

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/main.dart';
import 'package:psip_app/model/utils.dart';

class RegisterScreen extends StatefulWidget {
  final Function() onClickedSignIn;

  const RegisterScreen({super.key, required this.onClickedSignIn});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
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
                  height: 8,
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Masukkan email yang valid'
                          : null,
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
                  height: 8,
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: isVisible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value != null && value.length < 8
                      ? 'Kata sandi min. 8 karakter'
                      : null,
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
                  height: 8,
                ),
                TextFormField(
                  obscureText: isVisible2,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
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
                if (!isNext) ...{
                  const SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: 'Nomor telepon',
                      hintText: 'Masukkan nomor telepon anda',
                      prefixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                          ),
                          Icon(Icons.phone),
                          SizedBox(
                            width: 12.5,
                          ),
                          Text(
                            '(+62) ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
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
                    height: 8,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.go,
                    decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat anda',
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
                },
                const SizedBox(
                  height: 20,
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
                  onPressed: () {
                    signUp();
                  },
                  child: Text(
                    "Daftar",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: divider,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      45,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  icon: SizedBox(
                    height: MediaQuery.of(context).size.width / 9.5,
                    child: Image.asset(
                      'assets/icons/google.png',
                      repeat: ImageRepeat.noRepeat,
                    ),
                  ),
                  label: Text(
                    "Daftar dengan google",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
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
                            ..onTap = widget.onClickedSignIn,
                          text: 'Masuk',
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future signUp() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print(e);
      }

      Utils.showSnackBar(e.message);
    }
    navigatorKey.currentState!.popUntil(
      (route) {
        return route.isFirst;
      },
    );
  }
}
