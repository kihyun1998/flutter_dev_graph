import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/login_form.dart';
import '../../../shared/widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingIndicator();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: LoginForm(
        emailController: _emailController,
        passwordController: _passwordController,
        onSubmit: _login,
      ),
    );
  }

  void _login() async {
    setState(() => _loading = true);
    await _authService.login(_emailController.text, _passwordController.text);
    setState(() => _loading = false);
  }
}
