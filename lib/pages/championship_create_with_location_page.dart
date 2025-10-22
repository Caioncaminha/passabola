import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/championship_model.dart';
import '../data/location_model.dart';
import '../widgets/location_picker_widget.dart';

class ChampionshipCreateWithLocationPage extends StatefulWidget {
  const ChampionshipCreateWithLocationPage({super.key});

  @override
  State<ChampionshipCreateWithLocationPage> createState() =>
      _ChampionshipCreateWithLocationPageState();
}

class _ChampionshipCreateWithLocationPageState
    extends State<ChampionshipCreateWithLocationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  LocationData? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Campeonato'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createChampionship,
            child: Text(
              'Criar',
              style: KTextStyle.buttonText.copyWith(
                color: KConstants.textLightColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              TextFormField(
                controller: _titleController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Título do Campeonato',
                  hintText: 'Ex: Copa de Futebol 2024',
                  prefixIcon: Icons.sports_soccer,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva o campeonato...',
                  prefixIcon: Icons.description,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Localização (texto)
              TextFormField(
                controller: _locationController,
                decoration: KInputDecoration.textFieldDecoration(
                  labelText: 'Localização (texto)',
                  hintText: 'Ex: Campo Municipal, São Paulo - SP',
                  prefixIcon: Icons.location_on,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Localização é obrigatória';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Seletor de localização no mapa
              Text(
                'Localização no Mapa',
                style: KTextStyle.titleText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione a localização exata do campeonato no mapa para facilitar a navegação dos participantes.',
                style: KTextStyle.bodyText.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              LocationPickerWidget(
                initialLocation: _selectedLocation,
                hintText: 'Busque o local do campeonato...',
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Informações da localização selecionada
              if (_selectedLocation != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Localização Selecionada',
                            style: KTextStyle.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedLocation!.formattedAddress.isNotEmpty
                            ? _selectedLocation!.formattedAddress
                            : 'Coordenadas: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: KTextStyle.smallText.copyWith(
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botão de criar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createChampionship,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KConstants.primaryColor,
                    foregroundColor: KConstants.textLightColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : const Text('Criar Campeonato'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createChampionship() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Aqui você integraria com o ChampionshipService
      // para criar o campeonato com a localização

      final championship = Championship(
        id: '', // Será gerado pelo serviço
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        locationData: _selectedLocation,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'current_user_id', // Obter do usuário logado
        organizerName: 'Nome do Organizador', // Obter do usuário logado
      );

      print('DEBUG: Campeonato criado:');
      print('  Título: ${championship.title}');
      print('  Localização: ${championship.location}');
      print(
        '  Coordenadas: ${championship.locationData?.latitude}, ${championship.locationData?.longitude}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campeonato criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar campeonato: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
