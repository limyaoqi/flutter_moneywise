import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/widget/dialogs/confirm_delete_dialog.dart';

class UserProfileMenu extends StatelessWidget {
  final User? user;

  const UserProfileMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle),
      onPressed: () => show(context),
    );
  }

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary,
                    backgroundImage:
                        user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                    child:
                        user?.photoURL == null
                            ? Text(
                              user?.displayName?.isNotEmpty == true
                                  ? user!.displayName![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Logout button
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.expense),
                title: const Text('Sign Out'),
                onTap: () {
                  // First close the modal bottom sheet
                  Navigator.pop(context);
                  // Show confirmation dialog
                  ConfirmDeleteDialog.show(
                    context: context,
                    title: 'Confirm Sign Out',
                    content: 'Are you sure you want to sign out?',
                    cancelText: 'Cancel',
                    confirmText: 'Sign Out',
                    confirmColor: AppColors.expense,
                    onConfirm: () async {
                      // Then sign out (this will trigger the GoRouter redirect)
                      await FirebaseAuth.instance.signOut();
                      await GoogleSignIn().signOut();
                      // No need to navigate manually, GoRouter will handle it
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
