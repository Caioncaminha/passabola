import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color corPrincipal = Color(0xFF6A446F);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: corPrincipal,
      elevation: 0,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.white,
      iconSize: 30,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Início"),
        BottomNavigationBarItem(icon: Icon(Icons.star_border), label: "Eventos"),
        BottomNavigationBarItem(icon: Icon(Icons.sports_soccer_outlined), label: "Jogos"),
        BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: "Notícias"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
      ],
    );
  }
}