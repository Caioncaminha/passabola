import 'package:flutter/material.dart';
import 'package:passaabola/pages/jogos_page.dart';
import 'perfil_page.dart';
import 'testeAPI.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/article_list_widget.dart';
import 'home_page.dart';
import 'admin_page.dart';
import '../data/auth_roles.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  UserRole? _role;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRole();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recarregar role quando o app voltar ao foco
      _loadRole();
    }
  }

  Future<void> _loadRole() async {
    // Limpar cache antes de carregar o role para garantir dados atualizados
    RoleService.clearAllCaches();
    final role = await RoleService().getCurrentUserRole();
    if (!mounted) return;
    setState(() {
      _role = role;
    });
  }

  // Páginas alinhadas às 5 abas do BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    Api(),
    JogosPage(),
    ArticleListWidget(showAllArticles: false),
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
      floatingActionButton: _selectedIndex == 0 && _role == UserRole.admin
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AdminPage()));
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Painel Admin'),
            )
          : null,
    );
  }
}
