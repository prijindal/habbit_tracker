import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helpers/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredential> _getCreds(String type) async {
    if (type == "login") {
      final creds = await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      return creds;
    } else {
      final creds = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      return creds;
    }
  }

  Future<void> _signUpUser() async {
    try {
      final creds = await _getCreds("signup");
      if (context.mounted) {
        Navigator.of(context).pop<UserCredential>(creds);
      }
    } on FirebaseAuthException catch (e, stack) {
      AppLogger.instance.e("Error while signing up", e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Error while signing up"),
          ),
        );
      }
    }
  }

  Future<void> _authUser() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final creds = await _getCreds("login");
      if (context.mounted) {
        Navigator.of(context).pop<UserCredential>(creds);
      }
    } on FirebaseAuthException catch (e, stack) {
      AppLogger.instance.e("Error while logging in", e, stack);
      if (e.code == "user-not-found") {
        await _signUpUser();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Error while logging in"),
            ),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              enabled: !_isLoading,
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              enabled: !_isLoading,
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _isLoading
                  ? null
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _authUser();
                        }
                      },
                      child: const Text('Login'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
