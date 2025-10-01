import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/constants.dart';

class AdminAnnouncementsPage extends StatefulWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  State<AdminAnnouncementsPage> createState() => _AdminAnnouncementsPageState();
}

class _AdminAnnouncementsPageState extends State<AdminAnnouncementsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('avisos').add({
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': 'admin', // Pode ser expandido para incluir UID do admin
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aviso criado com sucesso!'),
          backgroundColor: KConstants.successColor,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar aviso: $e'),
          backgroundColor: KConstants.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Aviso'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createAnnouncement,
            child: Text(
              'Publicar',
              style: KTextStyle.buttonText.copyWith(
                color: KConstants.textLightColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KConstants.spacingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Criar Novo Aviso', style: KTextStyle.largeTitleText),
              const SizedBox(height: KConstants.spacingMedium),
              Text(
                'Este aviso será exibido para todos os usuários do app.',
                style: KTextStyle.bodyText.copyWith(
                  color: KConstants.textSecondaryColor,
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de título
              TextFormField(
                controller: _titleController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Título do Aviso',
                  hintText: 'Ex: Manutenção programada',
                  prefixIcon: Icons.title,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  if (value.trim().length < 5) {
                    return 'Título deve ter pelo menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Campo de mensagem
              TextFormField(
                controller: _messageController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Mensagem',
                  hintText: 'Digite o conteúdo do aviso...',
                  prefixIcon: Icons.message,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mensagem é obrigatória';
                  }
                  if (value.trim().length < 10) {
                    return 'Mensagem deve ter pelo menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: KConstants.spacingMedium),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createAnnouncement,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KConstants.primaryColor,
                        foregroundColor: KConstants.textLightColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: KConstants.spacingMedium,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: KConstants.textLightColor,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Publicar Aviso'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
