import 'package:flutter/material.dart';
import '../data/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = KConstants.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu, 
          color: KConstants.textLightColor, 
          size: 30
        ),
        onPressed: () {
          // Lógica para abrir o menu lateral (Drawer), se houver.
        },
      ),
      title: Text(
        title,
        style: KTextStyle.titleText.copyWith(
          color: KConstants.textLightColor,
          fontSize: KConstants.fontSizeLarge,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}