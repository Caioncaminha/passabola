import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/location_model.dart';

class CEPService {
  static const String _viaCEPBaseUrl = 'https://viacep.com.br/ws';

  /// Busca endereço pelo CEP usando a API ViaCEP
  static Future<LocationData?> getAddressByCEP(String cep) async {
    try {
      // Remove formatação do CEP
      String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanCEP.length != 8) {
        throw Exception('CEP deve ter 8 dígitos');
      }

      final url = '$_viaCEPBaseUrl/$cleanCEP/json/';
      print('DEBUG: Buscando CEP: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['erro'] == true) {
          throw Exception('CEP não encontrado');
        }

        // Monta o endereço completo
        String address = '';
        List<String> addressParts = [];

        if (data['logradouro'] != null && data['logradouro'].isNotEmpty) {
          addressParts.add(data['logradouro']);
        }

        if (data['bairro'] != null && data['bairro'].isNotEmpty) {
          addressParts.add(data['bairro']);
        }

        if (data['localidade'] != null && data['localidade'].isNotEmpty) {
          addressParts.add(data['localidade']);
        }

        if (data['uf'] != null && data['uf'].isNotEmpty) {
          addressParts.add(data['uf']);
        }

        address = addressParts.join(', ');

        return LocationData(
          latitude: 0.0, // ViaCEP não fornece coordenadas
          longitude: 0.0,
          address: address,
          city: data['localidade'],
          state: data['uf'],
          country: 'Brasil',
          postalCode: cleanCEP,
        );
      } else {
        throw Exception('Erro ao buscar CEP: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Erro ao buscar CEP: $e');
      rethrow;
    }
  }

  /// Valida se o CEP está no formato correto
  static bool isValidCEP(String cep) {
    String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanCEP.length == 8;
  }

  /// Formata CEP para exibição
  static String formatCEP(String cep) {
    String cleanCEP = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCEP.length == 8) {
      return '${cleanCEP.substring(0, 5)}-${cleanCEP.substring(5)}';
    }
    return cep;
  }
}

class AddressService {
  /// Busca coordenadas de um endereço usando Geocoding
  static Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      // Aqui você integraria com o LocationService que já criamos
      // ou com outra API de geocoding

      print('DEBUG: Buscando coordenadas para: $address');

      // Exemplo de integração com LocationService:
      // final locations = await LocationService.searchAddresses(address);
      // if (locations.isNotEmpty) {
      //   return locations.first;
      // }

      return null;
    } catch (e) {
      print('DEBUG: Erro ao buscar coordenadas: $e');
      return null;
    }
  }

  /// Combina busca por CEP com geocoding para obter coordenadas
  static Future<LocationData?> getFullAddressData(String cep) async {
    try {
      // Primeiro busca o endereço pelo CEP
      final addressData = await CEPService.getAddressByCEP(cep);

      if (addressData == null) {
        return null;
      }

      // Depois busca as coordenadas
      final coordinates = await getCoordinatesFromAddress(
        addressData.formattedAddress,
      );

      if (coordinates != null) {
        // Combina os dados do CEP com as coordenadas
        return addressData.copyWith(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
        );
      }

      return addressData;
    } catch (e) {
      print('DEBUG: Erro ao buscar dados completos do endereço: $e');
      return null;
    }
  }
}
