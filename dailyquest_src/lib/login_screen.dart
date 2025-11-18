import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'colors.dart';
import 'db_helper_User.dart';
import 'auth_buttons.dart';
import 'quests_screen.dart';
import 'profile_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Login validation is handled by db_helper.validateLogin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quest'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Text - visually shifted up so it sits between the AppBar and inputs
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: Text(
                    'Welcome to Daily Quest',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primColor_dGreen),
                  ),
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: inputTextColor),
                  cursorColor: inputCursorColor,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: inputLabelColor),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter username' : null,
                ),
                const SizedBox(height: 12),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: inputTextColor),
                  cursorColor: inputCursorColor,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: inputLabelColor),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Please enter password' : null,
                ),
                const SizedBox(height: 16),

                // Login Button
                LoginButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      // User input for username and password
                      final user = _usernameController.text;
                      final pass = _hashPassword(_passwordController.text);
                      final validLogin = await DbHelperUser.validateLogin(user, pass);

                      if (validLogin) {
                        final loggedInUser = await DbHelperUser.getUser(user);

                        if (loggedInUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not found')),
                          );
                          return;
                        }

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ProfileScaffold(
                              user: loggedInUser,
                              body: QuestsCategoryScreen(user: loggedInUser),
                            ),
                          ),
                        );

                      // Invalid login
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid username or password')),
                        );
                      }
                    }
                  },
                  child: const Text('Login'),
                ),

                const SizedBox(height: 12),

                // Sign Up Button
                SignUpButton(
                  onPressed: () async {
                    // User input for username and password
                    final uName = _usernameController.text;
                    final pWord = _hashPassword(_passwordController.text);

                    // Handle empty input case
                    if (uName.isEmpty || pWord.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter username and password to sign up')),
                      );
                      return;
                    }

                    // Check if user already exists
                    if (await DbHelperUser.userExists(uName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Username already exists')),
                      );
                      return;
                    }

                    // Valid credentials, create user
                    await DbHelperUser.insertUser(uName, pWord);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User $uName signed up successfully!')),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
