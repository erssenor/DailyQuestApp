import 'package:flutter/material.dart';
import 'colors.dart';

typedef ButtonCallback = void Function();

// Shared button style for authentication buttons
final ButtonStyle authButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: primColor_dGreen,
  foregroundColor: Colors.white,
  padding: const EdgeInsets.symmetric(vertical: 16),
);

class LoginButton extends StatelessWidget {
  final ButtonCallback onPressed;
  final Widget child;

  const LoginButton({required this.onPressed, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, style: authButtonStyle, child: child);
  }
}

class SignUpButton extends StatelessWidget {
  final ButtonCallback onPressed;
  final Widget child;

  const SignUpButton({required this.onPressed, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, style: authButtonStyle, child: child);
  }
}
