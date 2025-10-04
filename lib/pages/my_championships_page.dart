import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/championship_model.dart';
import '../data/championship_service.dart';
import '../data/constants.dart';

class MyChampionshipsPage extends StatefulWidget {
  const MyChampionshipsPage({Key? key}) : super(key: key);

  @override
  State<MyChampionshipsPage> createState() => _MyChampionshipsPageState();
}

class _MyChampionshipsPageState extends State<MyChampionshipsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ChampionshipRegistration> _registrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyRegistrations() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('DEBUG: Usuário não autenticado');
        return;
      }

      print('DEBUG: Carregando inscrições para usuário: ${user.uid}');

      // Debug: verificar diretamente no Firestore
      await _debugFirestoreRegistrations(user.uid);

      final registrations = await ChampionshipService.getUserAllRegistrations(
        user.uid,
      );

      print('DEBUG: Inscrições encontradas: ${registrations.length}');
      for (final reg in registrations) {
        print('DEBUG: - ${reg.championshipTitle} (${reg.championshipStatus})');
      }

      if (mounted) {
        setState(() {
          _registrations = registrations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar inscrições: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar suas inscrições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _debugFirestoreRegistrations(String userId) async {
    try {
      print('DEBUG: Verificando inscrições diretamente no Firestore...');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('championship_registrations')
          .where('userId', isEqualTo: userId)
          .get();

      print(
        'DEBUG: Total de documentos encontrados: ${querySnapshot.docs.length}',
      );

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        print('DEBUG: Documento ${doc.id}:');
        print('DEBUG: - championshipId: ${data['championshipId']}');
        print('DEBUG: - userId: ${data['userId']}');
        print('DEBUG: - userName: ${data['userName']}');
        print('DEBUG: - userEmail: ${data['userEmail']}');
        print('DEBUG: - teamId: ${data['teamId']}');
        print('DEBUG: - registeredAt: ${data['registeredAt']}');
      }
    } catch (e) {
      print('DEBUG: Erro ao verificar Firestore: $e');
    }
  }

  Future<void> _cancelRegistration(
    ChampionshipRegistration registration,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Inscrição'),
        content: const Text(
          'Tem certeza que deseja cancelar sua inscrição neste campeonato?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ChampionshipService.cancelUserRegistration(registration.id);
      await _loadMyRegistrations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição cancelada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar inscrição: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Campeonatos'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadMyRegistrations,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Inscrições Ativas', icon: Icon(Icons.event_available)),
            Tab(text: 'Histórico', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveRegistrations(),
                _buildRegistrationHistory(),
              ],
            ),
    );
  }

  Widget _buildActiveRegistrations() {
    final activeRegistrations = _registrations.where((reg) {
      return reg.championshipStatus == ChampionshipStatus.registrationOpen ||
          reg.championshipStatus == ChampionshipStatus.registrationClosed ||
          reg.championshipStatus == ChampionshipStatus.ongoing;
    }).toList();

    if (activeRegistrations.isEmpty) {
      return _buildEmptyState(
        'Nenhuma inscrição ativa',
        'Você não está inscrito em nenhum campeonato no momento.',
        Icons.event_available,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeRegistrations.length,
        itemBuilder: (context, index) {
          final registration = activeRegistrations[index];
          return _buildRegistrationCard(registration, showCancelButton: true);
        },
      ),
    );
  }

  Widget _buildRegistrationHistory() {
    final historyRegistrations = _registrations.where((reg) {
      return reg.championshipStatus == ChampionshipStatus.finished ||
          reg.championshipStatus == ChampionshipStatus.cancelled;
    }).toList();

    if (historyRegistrations.isEmpty) {
      return _buildEmptyState(
        'Nenhum histórico',
        'Você ainda não participou de nenhum campeonato finalizado.',
        Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historyRegistrations.length,
        itemBuilder: (context, index) {
          final registration = historyRegistrations[index];
          return _buildRegistrationCard(registration, showCancelButton: false);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadMyRegistrations,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: KConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DEBUG: Total de inscrições carregadas: ${_registrations.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationCard(
    ChampionshipRegistration registration, {
    required bool showCancelButton,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    registration.championshipTitle ?? 'Campeonato',
                    style: KTextStyle.cardTitleText,
                  ),
                ),
                _buildStatusChip(
                  registration.championshipStatus ?? ChampionshipStatus.draft,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              registration.championshipDescription ??
                  'Descrição não disponível',
              style: KTextStyle.bodyText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Informações da inscrição
            _buildInfoRow(
              Icons.location_on,
              registration.championshipLocation ?? 'Local não informado',
            ),

            const SizedBox(height: 4),

            _buildInfoRow(
              Icons.person,
              registration.registrationType == RegistrationType.teamOnly
                  ? 'Time: ${registration.teamName ?? "N/A"}'
                  : 'Individual',
            ),

            const SizedBox(height: 4),

            _buildInfoRow(
              Icons.calendar_today,
              'Inscrito em: ${_formatDate(registration.registeredAt)}',
            ),

            if (registration.isConfirmed) ...[
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.check_circle,
                'Confirmado',
                color: Colors.green[600],
              ),
            ],

            if (registration.isPaid) ...[
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.payment,
                'Pagamento confirmado',
                color: Colors.green[600],
              ),
            ],

            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewChampionshipDetails(registration),
                    child: const Text('Ver Detalhes'),
                  ),
                ),

                if (registration.championshipStatus ==
                        ChampionshipStatus.registrationOpen ||
                    registration.championshipStatus ==
                        ChampionshipStatus.registrationClosed ||
                    registration.championshipStatus ==
                        ChampionshipStatus.ongoing) ...[
                  const SizedBox(width: 8),
                ],
              ],
            ),

            if (showCancelButton &&
                registration.championshipStatus ==
                    ChampionshipStatus.registrationOpen) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _cancelRegistration(registration),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancelar Inscrição'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ChampionshipStatus status) {
    Color color;
    String text;

    switch (status) {
      case ChampionshipStatus.registrationOpen:
        color = Colors.green;
        text = 'Inscrições Abertas';
        break;
      case ChampionshipStatus.registrationClosed:
        color = Colors.orange;
        text = 'Inscrições Fechadas';
        break;
      case ChampionshipStatus.ongoing:
        color = Colors.blue;
        text = 'Em Andamento';
        break;
      case ChampionshipStatus.finished:
        color = Colors.grey;
        text = 'Finalizado';
        break;
      case ChampionshipStatus.cancelled:
        color = Colors.red;
        text = 'Cancelado';
        break;
      default:
        color = Colors.grey;
        text = 'Desconhecido';
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? KConstants.textSecondaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: KTextStyle.smallText.copyWith(
              color: color ?? KConstants.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewChampionshipDetails(ChampionshipRegistration registration) {
    // Navegar para página de detalhes do campeonato
    // Por enquanto, apenas mostrar um dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(registration.championshipTitle ?? 'Campeonato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local: ${registration.championshipLocation ?? 'Não informado'}',
            ),
            const SizedBox(height: 8),
            Text('Tipo: ${registration.registrationType.name}'),
            const SizedBox(height: 8),
            Text(
              'Status: ${registration.championshipStatus?.name ?? 'Desconhecido'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
