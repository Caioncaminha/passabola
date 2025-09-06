import 'package:flutter/material.dart';
import 'perfil_page.dart';
import 'testeAPI.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../data/constants.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Páginas alinhadas às 5 abas do BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Center(child: Text('Página de Eventos', style: KTextStyle.titleText)),
    const Api(),
    Center(child: Text('Página de Notícias', style: KTextStyle.titleText)),
    PerfilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "PASSA A BOLA"),
      body: _pages.elementAt(_selectedIndex),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
