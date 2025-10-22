import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'location_model.dart';

class LocationService {
  /// Verifica e solicita permissões de localização
  static Future<bool> requestLocationPermission() async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('DEBUG: Serviço de localização desabilitado');
        return false;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('DEBUG: Permissão de localização negada');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('DEBUG: Permissão de localização negada permanentemente');
        return false;
      }

      print('DEBUG: Permissão de localização concedida');
      return true;
    } catch (e) {
      print('DEBUG: Erro ao verificar permissões: $e');
      return false;
    }
  }

  /// Obtém a localização atual do usuário
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Verificar permissões
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Permissão de localização necessária');
      }

      // Obter posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print(
        'DEBUG: Posição obtida: ${position.latitude}, ${position.longitude}',
      );

      // Obter endereço a partir das coordenadas
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: _formatAddress(placemark),
          city: placemark.locality,
          state: placemark.administrativeArea,
          country: placemark.country,
          postalCode: placemark.postalCode,
        );
      } else {
        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (e) {
      print('DEBUG: Erro ao obter localização atual: $e');
      return null;
    }
  }

  /// Busca endereços a partir de uma string de busca
  static Future<List<LocationData>> searchAddresses(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      List<Location> locations = await locationFromAddress(query);

      List<LocationData> results = [];
      for (Location location in locations) {
        // Obter detalhes do endereço
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          results.add(
            LocationData(
              latitude: location.latitude,
              longitude: location.longitude,
              address: _formatAddress(placemark),
              city: placemark.locality,
              state: placemark.administrativeArea,
              country: placemark.country,
              postalCode: placemark.postalCode,
            ),
          );
        } else {
          results.add(
            LocationData(
              latitude: location.latitude,
              longitude: location.longitude,
            ),
          );
        }
      }

      print('DEBUG: ${results.length} endereços encontrados para "$query"');
      return results;
    } catch (e) {
      print('DEBUG: Erro ao buscar endereços: $e');
      return [];
    }
  }

  /// Obtém endereço a partir de coordenadas
  static Future<LocationData?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return LocationData(
          latitude: latitude,
          longitude: longitude,
          address: _formatAddress(placemark),
          city: placemark.locality,
          state: placemark.administrativeArea,
          country: placemark.country,
          postalCode: placemark.postalCode,
        );
      }

      return LocationData(latitude: latitude, longitude: longitude);
    } catch (e) {
      print('DEBUG: Erro ao obter endereço das coordenadas: $e');
      return null;
    }
  }

  /// Formata o endereço a partir de um Placemark
  static String _formatAddress(Placemark placemark) {
    List<String> addressParts = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressParts.add(placemark.street!);
    }

    if (placemark.subThoroughfare != null &&
        placemark.subThoroughfare!.isNotEmpty) {
      addressParts.add(placemark.subThoroughfare!);
    }

    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      addressParts.add(placemark.thoroughfare!);
    }

    return addressParts.join(', ');
  }

  /// Verifica se o GPS está habilitado
  static Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('DEBUG: Erro ao verificar serviço de localização: $e');
      return false;
    }
  }

  /// Abre as configurações de localização do dispositivo
  static Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      print('DEBUG: Erro ao abrir configurações de localização: $e');
    }
  }

  /// Abre as configurações de permissões do app
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('DEBUG: Erro ao abrir configurações do app: $e');
    }
  }
}
