import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/constants.dart';
import '../data/location_model.dart';
import '../data/location_service.dart';
import '../utils/formatters.dart';

class AddressPickerWidget extends StatefulWidget {
  final String? initialAddress;
  final LocationData? initialLocation;
  final Function(String address, LocationData? location) onAddressSelected;
  final String? labelText;
  final String? hintText;
  final bool isRequired;

  const AddressPickerWidget({
    super.key,
    this.initialAddress,
    this.initialLocation,
    required this.onAddressSelected,
    this.labelText,
    this.hintText,
    this.isRequired = false,
  });

  @override
  State<AddressPickerWidget> createState() => _AddressPickerWidgetState();
}

class _AddressPickerWidgetState extends State<AddressPickerWidget> {
  final TextEditingController _addressController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  List<LocationData> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress ?? '';
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de endereço
        TextFormField(
          controller: _addressController,
          decoration: KInputDecoration.textFieldDecoration(
            labelText: widget.labelText ?? 'Endereço',
            hintText: widget.hintText ?? 'Digite o endereço completo...',
            prefixIcon: Icons.location_on,
            suffixIcon: _addressController.text.isNotEmpty ? Icons.clear : null,
          ),
          onChanged: _onAddressChanged,
          onFieldSubmitted: _onAddressSubmitted,
          validator: widget.isRequired ? Validators.address : null,
        ),

        const SizedBox(height: 8),

        // Botões de ação
        Row(
          children: [
            if (_addressController.text.isNotEmpty)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAddress,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            if (_addressController.text.isNotEmpty) const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _toggleMap,
                icon: Icon(_showMap ? Icons.map : Icons.map_outlined),
                label: Text(_showMap ? 'Ocultar Mapa' : 'Mostrar Mapa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KConstants.primaryColor,
                  side: BorderSide(color: KConstants.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Minha Localização'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Resultados da busca
        if (_searchResults.isNotEmpty) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: KConstants.primaryColor,
                  ),
                  title: Text(
                    location.address ?? 'Endereço não disponível',
                    style: KTextStyle.bodyText,
                  ),
                  subtitle: Text(
                    location.shortAddress,
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  onTap: () => _selectAddress(location),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Mapa (se habilitado)
        if (_showMap) ...[
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildMap(),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Informações da localização selecionada
        if (_selectedLocation != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localização Confirmada',
                        style: KTextStyle.smallText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: KTextStyle.smallText.copyWith(
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Mensagem de erro
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red[400]),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar mapa',
              style: KTextStyle.bodyText.copyWith(color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _retryMap,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target:
            _selectedLocation ?? const LatLng(-23.5505, -46.6333), // São Paulo
        zoom: 15.0,
      ),
      markers: _selectedLocation != null
          ? {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _selectedLocation!,
                infoWindow: const InfoWindow(title: 'Localização Selecionada'),
              ),
            }
          : {},
      onTap: _onMapTapped,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
    );
  }

  void _onAddressChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedLocation = null;
      });
      widget.onAddressSelected('', null);
      return;
    }

    _searchAddresses(value);
  }

  void _onAddressSubmitted(String value) {
    _searchAddresses(value);
  }

  Future<void> _searchAddresses(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _error = null;
    });

    try {
      final results = await LocationService.searchAddresses(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao buscar endereços: $e';
        });
      }
    }
  }

  void _selectAddress(LocationData location) {
    setState(() {
      _selectedLocation = LatLng(location.latitude, location.longitude);
      _searchResults = [];
      _addressController.text = location.formattedAddress.isNotEmpty
          ? location.formattedAddress
          : '${location.latitude}, ${location.longitude}';
    });

    _moveMapToLocation(_selectedLocation!);
    widget.onAddressSelected(_addressController.text, location);
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromCoordinates(location);
  }

  void _moveMapToLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _selectedLocation = LatLng(location.latitude, location.longitude);
          _addressController.text = location.formattedAddress.isNotEmpty
              ? location.formattedAddress
              : '${location.latitude}, ${location.longitude}';
          _isLoading = false;
        });
        _moveMapToLocation(_selectedLocation!);
        widget.onAddressSelected(_addressController.text, location);
      } else {
        setState(() {
          _error = 'Não foi possível obter sua localização atual';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao obter localização: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      final addressData = await LocationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (addressData != null && mounted) {
        setState(() {
          _addressController.text = addressData.formattedAddress.isNotEmpty
              ? addressData.formattedAddress
              : '${location.latitude}, ${location.longitude}';
        });
        widget.onAddressSelected(_addressController.text, addressData);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao obter endereço: $e';
        });
      }
    }
  }

  void _toggleMap() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  void _clearAddress() {
    setState(() {
      _addressController.clear();
      _selectedLocation = null;
      _searchResults = [];
      _error = null;
    });
    widget.onAddressSelected('', null);
  }

  void _retryMap() {
    setState(() {
      _error = null;
      _isLoading = false;
    });
  }
}
