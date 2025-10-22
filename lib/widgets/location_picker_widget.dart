import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/constants.dart';
import '../data/location_model.dart';
import '../data/location_service.dart';

class LocationPickerWidget extends StatefulWidget {
  final LocationData? initialLocation;
  final Function(LocationData) onLocationSelected;
  final String? hintText;

  const LocationPickerWidget({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.hintText,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  List<LocationData> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de busca
        TextFormField(
          controller: _searchController,
          decoration: KInputDecoration.textFieldDecoration(
            labelText: 'Buscar localização',
            hintText: widget.hintText ?? 'Digite o endereço do torneio...',
            prefixIcon: Icons.search,
            suffixIcon: _searchController.text.isNotEmpty ? Icons.clear : null,
          ),
          onChanged: _onSearchChanged,
          onFieldSubmitted: _onSearchSubmitted,
        ),

        const SizedBox(height: 16),

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
                  onTap: () => _selectLocation(location),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Mapa
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

        const SizedBox(height: 16),

        // Botões de ação
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Minha Localização'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: KConstants.primaryColor,
                  side: BorderSide(color: KConstants.primaryColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedLocation != null ? _confirmSelection : null,
                icon: const Icon(Icons.check),
                label: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KConstants.primaryColor,
                  foregroundColor: KConstants.textLightColor,
                ),
              ),
            ),
          ],
        ),

        // Informações da localização selecionada
        if (_selectedLocation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: KConstants.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: KTextStyle.smallText.copyWith(
                      color: KConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Mensagem de erro
        if (_error != null) ...[
          const SizedBox(height: 8),
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
      zoomControlsEnabled: false,
    );
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    _searchAddresses(value);
  }

  void _onSearchSubmitted(String value) {
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

  void _selectLocation(LocationData location) {
    setState(() {
      _selectedLocation = LatLng(location.latitude, location.longitude);
      _searchResults = [];
      _searchController.clear();
    });

    _moveMapToLocation(_selectedLocation!);
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
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
          _isLoading = false;
        });
        _moveMapToLocation(_selectedLocation!);
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

  void _confirmSelection() {
    if (_selectedLocation != null) {
      final locationData = LocationData(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );
      widget.onLocationSelected(locationData);
    }
  }

  void _retryMap() {
    setState(() {
      _error = null;
      _isLoading = false;
    });
  }
}
