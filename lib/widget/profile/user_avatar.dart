import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/widget/profile/user_profile_menu.dart';

class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    required this.user,
    this.radius = 16,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final profileMenu = UserProfileMenu(user: user);
        profileMenu.show(context);
      },
      child: CircleAvatar(
        backgroundColor: backgroundColor,
        radius: radius,
        backgroundImage:
            user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
        child:
            user?.photoURL == null
                ? Text(
                  user?.displayName?.isNotEmpty == true
                      ? user!.displayName![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.75,
                  ),
                )
                : null,
      ),
    );
  }
}
