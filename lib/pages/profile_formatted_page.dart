import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/location_model.dart';
import '../widgets/formatted_text_field.dart';
import '../widgets/address_picker_widget.dart';

class ProfileFormattedPage extends StatefulWidget {
  const ProfileFormattedPage({super.key});

  @override
  State<ProfileFormattedPage> createState() => _ProfileFormattedPageState();
}

class _ProfileFormattedPageState extends State<ProfileFormattedPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();

  LocationData? _selectedLocation;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _birthDateController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Completo'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Salvar',
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
              Text(
                'Dados Pessoais',
                style: KTextStyle.largeTitleText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Nome
              NameField(
                controller: _nameController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 16),

              // Email
              EmailField(
                controller: _emailController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 16),

              // Telefone
              PhoneField(
                controller: _phoneController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 16),

              // CPF
              CPFField(
                controller: _cpfController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 16),

              // RG
              RGField(
                controller: _rgController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 16),

              // Data de Nascimento
              BirthDateField(
                controller: _birthDateController,
                onChanged: (value) {
                  // Pode adicionar lógica adicional aqui
                },
              ),
              const SizedBox(height: 24),

              // Título para endereço
              Text(
                'Endereço',
                style: KTextStyle.largeTitleText.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // CEP
              CEPField(
                controller: _cepController,
                onChanged: (value) {
                  // Pode buscar endereço pelo CEP aqui
                  if (value.length == 9) {
                    // CEP completo
                    _searchAddressByCEP(value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Endereço com Google Maps
              AddressPickerWidget(
                initialAddress: _addressController.text,
                initialLocation: _selectedLocation,
                labelText: 'Endereço Completo',
                hintText: 'Digite o endereço completo...',
                isRequired: true,
                onAddressSelected: (address, location) {
                  setState(() {
                    _addressController.text = address;
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Localização Confirmada',
                            style: KTextStyle.bodyText.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
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
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
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
                      : const Text('Salvar Perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _searchAddressByCEP(String cep) async {
    // Remove formatação do CEP
    String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCEP.length == 8) {
      try {
        // Aqui você pode integrar com uma API de CEP como ViaCEP
        // Por enquanto, apenas simula a busca
        print('DEBUG: Buscando endereço para CEP: $cleanCEP');

        // Exemplo de como seria a integração:
        // final address = await ViaCEPService.getAddress(cleanCEP);
        // if (address != null) {
        //   _addressController.text = address.formattedAddress;
        //   _selectedLocation = address.locationData;
        // }
      } catch (e) {
        print('DEBUG: Erro ao buscar CEP: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Aqui você integraria com o serviço de perfil
      // para salvar os dados formatados

      final profileData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'rg': _rgController.text.trim(),
        'birthDate': _birthDateController.text.trim(),
        'cep': _cepController.text.trim(),
        'address': _addressController.text.trim(),
        'locationData': _selectedLocation?.toMap(),
      };

      print('DEBUG: Dados do perfil:');
      print('  Nome: ${profileData['name']}');
      print('  Email: ${profileData['email']}');
      print('  Telefone: ${profileData['phone']}');
      print('  CPF: ${profileData['cpf']}');
      print('  RG: ${profileData['rg']}');
      print('  Data de Nascimento: ${profileData['birthDate']}');
      print('  CEP: ${profileData['cep']}');
      print('  Endereço: ${profileData['address']}');
      print('  Localização: ${profileData['locationData']}');

      // Simula delay de salvamento
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil salvo com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar perfil: $e'),
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
