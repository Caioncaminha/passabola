import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/team_service.dart';
import '../data/team_model.dart';

class TeamCreatePage extends StatefulWidget {
  const TeamCreatePage({super.key});

  @override
  State<TeamCreatePage> createState() => _TeamCreatePageState();
}

class _TeamCreatePageState extends State<TeamCreatePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  bool _isLoading = false;
  TeamLevel _selectedLevel = TeamLevel.beginner;
  int _maxMembers = 11;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Time'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _onSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: KConstants.textLightColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Solicitar',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações sobre o sistema
              Container(
                padding: const EdgeInsets.all(KConstants.spacingMedium),
                decoration: BoxDecoration(
                  color: KConstants.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: KConstants.infoColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: KConstants.infoColor,
                      size: 20,
                    ),
                    const SizedBox(width: KConstants.spacingSmall),
                    Expanded(
                      child: Text(
                        'Sua solicitação será analisada por um administrador antes da aprovação.',
                        style: KTextStyle.smallText.copyWith(
                          color: KConstants.infoColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Nome do time
              TextFormField(
                controller: _nameController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Nome do Time',
                  hintText: 'Digite o nome do seu time',
                  prefixIcon: Icons.group,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nome do time é obrigatório'
                    : null,
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // URL da imagem
              TextFormField(
                controller: _imageUrlController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'URL da Imagem (opcional)',
                  hintText: 'https://exemplo.com/logo.jpg',
                  prefixIcon: Icons.image,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Nível do time
              Text(
                'Nível do Time',
                style: KTextStyle.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: KConstants.spacingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KConstants.spacingMedium,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: KConstants.borderColor),
                  borderRadius: BorderRadius.circular(
                    KConstants.borderRadiusMedium,
                  ),
                ),
                child: DropdownButtonFormField<TeamLevel>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: TeamLevel.values.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(_getLevelDisplayName(level)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Número máximo de membros
              Text(
                'Número Máximo de Membros',
                style: KTextStyle.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: KConstants.spacingSmall),
              Slider(
                value: _maxMembers.toDouble(),
                min: 5,
                max: 20,
                divisions: 15,
                label: _maxMembers.toString(),
                onChanged: (value) {
                  setState(() {
                    _maxMembers = value.round();
                  });
                },
                activeColor: KConstants.primaryColor,
              ),
              Center(
                child: Text(
                  '$_maxMembers membros',
                  style: KTextStyle.bodyText.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: KConstants.spacingLarge),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Descrição do Time',
                  hintText: 'Descreva seu time, objetivos, estilo de jogo...',
                ),
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Descrição é obrigatória'
                    : null,
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
                      onPressed: _isLoading ? null : _onSave,
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
                          : const Text('Solicitar Criação'),
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

  String _getLevelDisplayName(TeamLevel level) {
    switch (level) {
      case TeamLevel.beginner:
        return 'Iniciante';
      case TeamLevel.amateur:
        return 'Amador';
      case TeamLevel.semiPro:
        return 'Semi-profissional';
      case TeamLevel.professional:
        return 'Profissional';
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Criar solicitação de time
      await TeamService.createTeamRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        level: _selectedLevel,
        maxMembers: _maxMembers,
      );

      if (!mounted) return;

      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Solicitação de time enviada com sucesso! Aguarde a aprovação.',
          ),
          backgroundColor: KConstants.successColor,
        ),
      );

      // Voltar para a tela anterior
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar solicitação: $e'),
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
}
