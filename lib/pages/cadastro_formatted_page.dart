import 'package:flutter/material.dart';
import '../data/constants.dart';
import '../data/location_model.dart';
import '../widgets/formatted_text_field.dart';
import '../widgets/address_picker_widget.dart';
import '../services/cep_service.dart';

class CadastroFormattedPage extends StatefulWidget {
  const CadastroFormattedPage({super.key});

  @override
  State<CadastroFormattedPage> createState() => _CadastroFormattedPageState();
}

class _CadastroFormattedPageState extends State<CadastroFormattedPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
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
    _birthDateController.dispose();
    _cepController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
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
              NameField(controller: _nameController),
              const SizedBox(height: 16),

              // Email
              EmailField(controller: _emailController),
              const SizedBox(height: 16),

              // Telefone
              PhoneField(controller: _phoneController),
              const SizedBox(height: 16),

              // CPF
              CPFField(controller: _cpfController),
              const SizedBox(height: 16),

              // Data de Nascimento
              BirthDateField(controller: _birthDateController),
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

              // Botão de cadastrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                      : const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _searchAddressByCEP(String cep) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final addressData = await CEPService.getAddressByCEP(cep);

      if (addressData != null && mounted) {
        setState(() {
          _addressController.text = addressData.formattedAddress;
          _selectedLocation = addressData;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Endereço encontrado pelo CEP!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CEP não encontrado'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao buscar CEP: $e'),
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Aqui você integraria com o serviço de cadastro
      // para salvar os dados formatados

      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
        'birthDate': _birthDateController.text.trim(),
        'cep': _cepController.text.trim(),
        'address': _addressController.text.trim(),
        'locationData': _selectedLocation?.toMap(),
      };

      print('DEBUG: Dados do cadastro:');
      print('  Nome: ${userData['name']}');
      print('  Email: ${userData['email']}');
      print('  Telefone: ${userData['phone']}');
      print('  CPF: ${userData['cpf']}');
      print('  Data de Nascimento: ${userData['birthDate']}');
      print('  CEP: ${userData['cep']}');
      print('  Endereço: ${userData['address']}');
      print('  Localização: ${userData['locationData']}');

      // Simula delay de cadastro
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
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
