import 'package:flutter/material.dart';
import 'package:psip_app/screen/login_screen.dart';
import 'package:psip_app/screen/register_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return const LoginScreen();
    } else {
      return const RegisterScreen();
    }
  }

  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }
}
