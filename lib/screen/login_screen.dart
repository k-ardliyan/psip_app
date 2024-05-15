import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psip_app/main.dart';
import 'package:psip_app/model/utils.dart';
import 'package:psip_app/screen/forgot_sreen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginScreen({super.key, required this.onClickedSignUp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool isNext = true;
  void toggleNext() {
    setState(() {
      isNext = !isNext;
    });
  }

  bool isVisible = true;
  void toggleVisible() {
    setState(() {
      isVisible = !isVisible;
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
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
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
              if (isNext) ...{
                const SizedBox(height: 15),
                TextFormField(
                  controller: passwordController,
                  obscureText: isVisible,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Kata sandi',
                    hintText: 'Masukkan kata sandi anda',
                    prefixIcon: const Icon(Icons.vpn_key),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                        color: Colors.lightBlue,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ForgotPassworScreen();
                      }));
                    },
                  ),
                ),
              },
              const SizedBox(height: 20.0),
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
                onPressed: signIn,
                child: Text(
                  "Masuk",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isNext) ...{
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
                    "Masuk dengan google",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              },
              const SizedBox(
                height: 20,
              ),
              RichText(
                text: TextSpan(
                    text: 'Tidak memiliki akun? ',
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onClickedSignUp,
                        text: 'Daftar akun',
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
    );
  }

  Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
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
