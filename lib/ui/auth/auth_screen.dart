import 'package:flutter/material.dart';
import 'package:moneywise/data/repo/authRepo.dart';
import 'package:moneywise/theme/app_colors.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});
  final repo = Authrepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App Logo or Icon
              Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              // App Title
              const Text(
                'MoneyWise',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              // App Tagline
              const Text(
                'Smart money management for everyone',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const Spacer(),
              // Google Sign-in Button
              ElevatedButton.icon(
                onPressed: () async {
                  final user = await repo.signInWithGoogle();
                  if (user != null && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
