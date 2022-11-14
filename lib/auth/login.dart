import 'package:chat_app/main.dart';
import 'package:chat_app/screen/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:math' as math;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isVisible = true;
  bool isLoading = false;
  Color mainColor = const Color.fromARGB(255, 84, 0, 84);

  showSnackBar(String text) {
    SnackBar snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _login() async {
    bool error = false;
    isLoading = true;
    setState(() {});
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      error = true;
      if (e.code == 'user-not-found') {
        showSnackBar("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        showSnackBar("Wrong password provided for that user.");
      } else {
        showSnackBar('Invalid Email');
      }
    } catch (e) {
      showSnackBar(e.toString());
    } finally {
      isLoading = false;

      if (!error) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const ChatScreen();
          },
        ));
      } else {
        setState(() {});
      }
    }
  }

  _signup() async {
    bool error = false;
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      error = true;
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    } finally {
      if (!error) {
        print('Sign up Success');
      }
    }
  }

  _spinner() {
    return const SizedBox(
      height: 12,
      width: 12,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat,
                    size: 100,
                    color: mainColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: Icon(
                        Icons.chat,
                        size: 60,
                        color: mainColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 2.5,
              ),
              const Text(
                "Connect people around the world",
                style: TextStyle(fontSize: 10),
              ),
              const SizedBox(
                height: 80,
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: mainColor)),
                  )),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: isVisible,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                        icon: isVisible
                            ? const Icon(Icons.visibility_off)
                            : const Icon(Icons.visibility)),
                    hintText: 'Password'),
                onSubmitted: ((value) {
                  _login();
                }),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      minimumSize: const Size(double.infinity, 50)),
                  onPressed: () {
                    if (_emailController.text == "" ||
                        _passwordController.text == "") {
                      showSnackBar('Please fill this field');
                    } else {
                      _login();
                    }
                  },
                  icon: isLoading ? _spinner() : const SizedBox(),
                  label: const Text('Login to your account')),
            ],
          ),
        ),
      ),
    );
  }
}
