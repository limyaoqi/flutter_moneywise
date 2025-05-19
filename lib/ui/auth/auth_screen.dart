import 'package:flutter/material.dart';
import 'package:moneywise/data/repo/authRepo.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Authrepo();
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await repo.signInWithGoogle();
            if (user != null) {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
          child: const Text('Login with Google'),
        ),
      ),
    );
  }
}
