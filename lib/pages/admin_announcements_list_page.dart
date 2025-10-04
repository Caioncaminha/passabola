import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/announcement_service.dart';
import 'admin_announcements_page.dart';

class AdminAnnouncementsListPage extends StatefulWidget {
  const AdminAnnouncementsListPage({super.key});

  @override
  State<AdminAnnouncementsListPage> createState() =>
      _AdminAnnouncementsListPageState();
}

class _AdminAnnouncementsListPageState
    extends State<AdminAnnouncementsListPage> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final announcements = await AnnouncementService.getAllAnnouncements();

      if (mounted) {
        setState(() {
          _announcements = announcements;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Avisos'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: _loadAnnouncements,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createAnnouncement(),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar avisos',
              style: KTextStyle.titleText.copyWith(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: KTextStyle.bodyText.copyWith(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAnnouncements,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum aviso criado',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu primeiro aviso usando o botão +',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final isActive = announcement['isActive'] as bool;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isActive ? Icons.campaign : Icons.campaign_outlined,
                    color: isActive ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement['title'],
                        style: KTextStyle.titleText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive ? null : Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Por ${announcement['createdByName']}',
                        style: KTextStyle.smallText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Ativo' : 'Inativo',
                    style: KTextStyle.smallText.copyWith(
                      color: isActive ? Colors.green[700] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement['message'],
              style: KTextStyle.bodyText.copyWith(
                color: isActive ? null : Colors.grey[600],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (announcement['createdAt'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Criado em: ${_formatDate(announcement['createdAt'])}',
                style: KTextStyle.smallText.copyWith(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleStatus(announcement),
                    icon: Icon(
                      isActive ? Icons.visibility_off : Icons.visibility,
                    ),
                    label: Text(isActive ? 'Desativar' : 'Ativar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive ? Colors.orange : Colors.green,
                      side: BorderSide(
                        color: isActive ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editAnnouncement(announcement),
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KConstants.primaryColor,
                      side: BorderSide(color: KConstants.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteAnnouncement(announcement),
                    icon: const Icon(Icons.delete),
                    label: const Text('Deletar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createAnnouncement() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsPage()))
        .then((_) => _loadAnnouncements());
  }

  void _editAnnouncement(Map<String, dynamic> announcement) {
    // TODO: Implementar edição de avisos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edição de avisos será implementada em breve'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _toggleStatus(Map<String, dynamic> announcement) async {
    try {
      await AnnouncementService.toggleAnnouncementStatus(
        announcement['id'],
        !announcement['isActive'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              announcement['isActive']
                  ? 'Aviso desativado com sucesso!'
                  : 'Aviso ativado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadAnnouncements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alterar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAnnouncement(Map<String, dynamic> announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja deletar o aviso "${announcement['title']}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await AnnouncementService.deleteAnnouncement(announcement['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aviso "${announcement['title']}" deletado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadAnnouncements();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar aviso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
