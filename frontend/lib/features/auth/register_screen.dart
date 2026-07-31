import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _deptController = TextEditingController(text: 'CS');
  final _yearController = TextEditingController(text: '1');
  final _sectionController = TextEditingController(text: 'A');

  void _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final data = {
      'username': _usernameController.text,
      'display_name': _displayNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'department': _deptController.text,
      'year': int.parse(_yearController.text),
      'section': _sectionController.text,
    };

    await ref.read(authProvider.notifier).register(data);
    final state = ref.read(authProvider);

    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered Successfully. Please Login.')));
      context.go('/login');
    } else if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration Failed: ${state.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _displayNameController, decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _confirmPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder())),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authState.isLoading ? null : _register,
                child: authState.isLoading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
