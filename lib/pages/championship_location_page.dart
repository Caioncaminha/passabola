import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../data/constants.dart';
import '../data/championship_model.dart';

class ChampionshipLocationPage extends StatefulWidget {
  final Championship championship;

  const ChampionshipLocationPage({super.key, required this.championship});

  @override
  State<ChampionshipLocationPage> createState() =>
      _ChampionshipLocationPageState();
}

class _ChampionshipLocationPageState extends State<ChampionshipLocationPage> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
  }

  void _setupMarkers() {
    if (widget.championship.locationData != null) {
      final location = widget.championship.locationData!;
      _markers = {
        Marker(
          markerId: const MarkerId('championship_location'),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: widget.championship.title,
            snippet: location.formattedAddress.isNotEmpty
                ? location.formattedAddress
                : widget.championship.location,
          ),
        ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localização - ${widget.championship.title}'),
        backgroundColor: KConstants.primaryColor,
        foregroundColor: KConstants.textLightColor,
        actions: [
          IconButton(
            onPressed: _openInMaps,
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Abrir no Maps',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informações da localização
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KConstants.primaryColor.withValues(alpha: 0.1),
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: KConstants.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Local do Torneio',
                        style: KTextStyle.titleText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: KConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget
                              .championship
                              .locationData
                              ?.formattedAddress
                              .isNotEmpty ==
                          true
                      ? widget.championship.locationData!.formattedAddress
                      : widget.championship.location,
                  style: KTextStyle.bodyText,
                ),
                if (widget.championship.locationData != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Coordenadas: ${widget.championship.locationData!.latitude.toStringAsFixed(6)}, ${widget.championship.locationData!.longitude.toStringAsFixed(6)}',
                    style: KTextStyle.smallText.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Mapa
          Expanded(child: _buildMap()),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (widget.championship.locationData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Localização não disponível',
              style: KTextStyle.titleText.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Este campeonato não possui coordenadas de localização.',
              style: KTextStyle.bodyText.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final location = widget.championship.locationData!;

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        // Controller salvo para futuras operações
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 15.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  void _openInMaps() {
    if (widget.championship.locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localização não disponível para abrir no Maps'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final location = widget.championship.locationData!;
    final lat = location.latitude;
    final lng = location.longitude;

    // Para Android, usar geo: URI
    // Para iOS, usar maps: URI
    final String mapsUrl =
        'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(widget.championship.title)})';

    // TODO: Implementar abertura no app de mapas nativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo no Maps: $mapsUrl'),
        backgroundColor: KConstants.primaryColor,
      ),
    );
  }
}
