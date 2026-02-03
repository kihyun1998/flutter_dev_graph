import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Column(
        children: [
          CustomTextField(hint: 'Email', controller: _emailController),
          CustomTextField(hint: 'Password', controller: _passwordController, obscureText: true),
          CustomButton(text: 'Login', onPressed: _login),
        ],
      ),
    );
  }

  void _login() async {
    await _authService.login(_emailController.text, _passwordController.text);
  }
}
