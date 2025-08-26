import 'package:flutter/material.dart';
import 'jogadoras_page.dart';
import 'perfil_page.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0; // Começa na primeira página (Índice 0)

  static const List<Widget> _pages = <Widget>[
    JogadorasPage(), // Índice 0
    Center(child: Text('Página de Eventos')), // Índice 1 (Placeholder)
    Center(child: Text('Página de Jogos')), // Índice 2 (Placeholder)
    Center(child: Text('Página de Notícias')), // Índice 3 (Placeholder)
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