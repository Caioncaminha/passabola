import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0xFF6A446F),
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
        onPressed: () {
          // Lógica para abrir o menu lateral (Drawer), se houver.
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}