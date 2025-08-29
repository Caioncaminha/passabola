import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_page.dart';
import 'perfil_page.dart';
import 'jogadoras_page.dart';
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Lista de todas as páginas principais do app
  static const List<Widget> _pages = <Widget>[
    HomePage(), // Índice 0
    JogadorasPage(), // Índice 1
    Center(child: Text('Página de Jogos')), // Índice 2
    Center(child: Text('Página de Notícias')), // Índice 3
    PerfilPage(), // Índice 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "PASSA A BOLA"
      ),
      body: _pages.elementAt(_selectedIndex),
      
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}