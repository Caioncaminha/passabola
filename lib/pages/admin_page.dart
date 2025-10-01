import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/auth_roles.dart';
import '../data/cache_manager.dart';
import '../data/article_service.dart';
import '../widgets/article_list_widget.dart';
import 'article_create_page.dart';
import 'admin_announcements_page.dart';
import 'admin_scout_creation_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with TickerProviderStateMixin {
  late TabController _tabController;
  UserRole? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkAdminRole();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminRole() async {
    // Limpar cache antes de verificar o role para garantir dados atualizados
    RoleService.clearAllCaches();
    final role = await RoleService().getCurrentUserRole();
    if (!mounted) return;

    setState(() {
      _userRole = role;
      _isLoading = false;
    });

    // Se não for admin, redirecionar
    if (role != UserRole.admin) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Acesso negado. Apenas administradores podem acessar esta área.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userRole != UserRole.admin) {
      return const Scaffold(body: Center(child: Text('Acesso negado')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: () => _showCacheOptions(context),
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar Cache',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: KConstants.textLightColor,
          labelColor: KConstants.textLightColor,
          unselectedLabelColor: KConstants.textLightColor.withValues(
            alpha: 0.7,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.article), text: 'Artigos'),
            Tab(icon: Icon(Icons.campaign), text: 'Avisos'),
            Tab(icon: Icon(Icons.person_add), text: 'Olheiros'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminArticlesTab(),
          AdminAnnouncementsTab(),
          AdminScoutCreationTab(),
        ],
      ),
    );
  }

  void _showCacheOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Limpar Cache de Roles'),
                subtitle: const Text('Força atualização das permissões'),
                onTap: () async {
                  Navigator.of(context).pop();
                  CacheManager.clearRoleCache();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache de roles limpo!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Limpar Cache Completo'),
                subtitle: const Text('Remove todos os dados em cache'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await CacheManager.clearAllCaches();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache completo limpo!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Forçar Atualização'),
                subtitle: const Text('Limpa cache e recarrega dados'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await CacheManager.forceRefresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dados atualizados!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminArticlesTab extends StatefulWidget {
  const AdminArticlesTab({super.key});

  @override
  State<AdminArticlesTab> createState() => _AdminArticlesTabState();
}

class _AdminArticlesTabState extends State<AdminArticlesTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabeçalho com ações
        Container(
          padding: const EdgeInsets.all(KConstants.spacingLarge),
          decoration: BoxDecoration(
            color: KConstants.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gerenciar Artigos',
                      style: KTextStyle.largeTitleText,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ArticleCreatePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Artigo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KConstants.primaryColor,
                      foregroundColor: KConstants.textLightColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: KConstants.spacingMedium,
                        vertical: KConstants.spacingSmall,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KConstants.spacingMedium),

              // Barra de pesquisa
              TextField(
                controller: _searchController,
                decoration: KInputDecoration.textFieldDecoration(
                  hintText: 'Pesquisar artigos...',
                  prefixIcon: Icons.search,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: KConstants.spacingMedium),

              // Estatísticas
              FutureBuilder<Map<String, int>>(
                future: ArticleService.getArticleStats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final stats = snapshot.data!;
                    return Row(
                      children: [
                        _buildStatCard(
                          'Total',
                          '${stats['total']}',
                          Icons.article,
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        _buildStatCard(
                          'Publicados',
                          '${stats['published']}',
                          Icons.public,
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        _buildStatCard(
                          'Rascunhos',
                          '${stats['draft']}',
                          Icons.edit,
                        ),
                        const SizedBox(width: KConstants.spacingSmall),
                        _buildStatCard(
                          'Visualizações',
                          '${stats['totalViews']}',
                          Icons.visibility,
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),

        // Lista de artigos
        Expanded(
          child: ArticleListWidget(
            showAllArticles: true,
            searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(KConstants.spacingSmall),
        decoration: BoxDecoration(
          color: KConstants.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(KConstants.borderRadiusSmall),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: KConstants.primaryColor),
            const SizedBox(height: KConstants.spacingExtraSmall),
            Text(
              value,
              style: KTextStyle.titleText.copyWith(
                color: KConstants.primaryColor,
              ),
            ),
            Text(
              label,
              style: KTextStyle.smallText.copyWith(
                color: KConstants.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminAnnouncementsTab extends StatelessWidget {
  const AdminAnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Gerenciar Avisos', style: KTextStyle.largeTitleText),
          const SizedBox(height: KConstants.spacingMedium),
          Text(
            'Crie avisos importantes que serão exibidos para todos os usuários.',
            style: KTextStyle.bodyText,
          ),
          const SizedBox(height: KConstants.spacingLarge),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminAnnouncementsPage(),
                ),
              );
            },
            icon: const Icon(Icons.campaign),
            label: const Text('Criar Novo Aviso'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.primaryColor,
              foregroundColor: KConstants.textLightColor,
              padding: const EdgeInsets.symmetric(
                vertical: KConstants.spacingMedium,
              ),
            ),
          ),
          const SizedBox(height: KConstants.spacingLarge),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(KConstants.spacingLarge),
              decoration: BoxDecoration(
                color: KConstants.backgroundColor,
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusLarge,
                ),
                border: Border.all(
                  color: KConstants.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: KConstants.spacingMedium),
                    Text(
                      'Lista de avisos será implementada aqui',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminScoutCreationTab extends StatelessWidget {
  const AdminScoutCreationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KConstants.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Criar Contas de Olheiros', style: KTextStyle.largeTitleText),
          const SizedBox(height: KConstants.spacingMedium),
          Text(
            'Crie novas contas de olheiros que terão acesso à dashboard de jogadoras.',
            style: KTextStyle.bodyText,
          ),
          const SizedBox(height: KConstants.spacingLarge),
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AdminScoutCreationImprovedPage(),
                ),
              );
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Criar Nova Conta de Olheiro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KConstants.primaryColor,
              foregroundColor: KConstants.textLightColor,
              padding: const EdgeInsets.symmetric(
                vertical: KConstants.spacingMedium,
              ),
            ),
          ),
          const SizedBox(height: KConstants.spacingLarge),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(KConstants.spacingLarge),
              decoration: BoxDecoration(
                color: KConstants.backgroundColor,
                borderRadius: BorderRadius.circular(
                  KConstants.borderRadiusLarge,
                ),
                border: Border.all(
                  color: KConstants.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: KConstants.spacingMedium),
                    Text(
                      'Lista de olheiros será implementada aqui',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
