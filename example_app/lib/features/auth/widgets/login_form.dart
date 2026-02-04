import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_button.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(controller: emailController),
        TextField(controller: passwordController, obscureText: true),
        CustomButton(text: 'Login', onPressed: onSubmit),
      ],
    );
  }
}
