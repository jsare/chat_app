import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) return;

    _form.currentState!.save();

    try {
      if (_isLogin) {
        final userCredentials = _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // TODO: Some Error message
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 128,
                bottom: 18,
                left: 18,
                right: 18,
              ),
              width: 100,
              child: Image.asset('assets/images/chat.png'),
            ),
            Card(
              margin: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            labelText: 'Email Address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please entered a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(
                            enabledBorder: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Please entered a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Login' : 'Signup'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Create account'
                                : 'I already have account',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}