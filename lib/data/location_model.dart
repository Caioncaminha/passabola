import 'dart:math';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  /// Cria um LocationData a partir de um Map
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      postalCode: map['postalCode'],
    );
  }

  /// Converte LocationData para Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }

  /// Cria uma cópia com campos atualizados
  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
    );
  }

  /// Retorna uma string formatada do endereço
  String get formattedAddress {
    final parts = <String>[];

    if (address != null && address!.isNotEmpty) {
      parts.add(address!);
    }

    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }

    if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }

    return parts.join(', ');
  }

  /// Retorna uma string resumida do endereço (cidade, estado)
  String get shortAddress {
    final parts = <String>[];

    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Localização não informada';
  }

  /// Verifica se a localização é válida
  bool get isValid {
    return latitude != 0.0 && longitude != 0.0;
  }

  /// Calcula a distância entre duas localizações em quilômetros
  double distanceTo(LocationData other) {
    const double earthRadius = 6371; // Raio da Terra em km

    final double lat1Rad = latitude * (3.14159265359 / 180);
    final double lat2Rad = other.latitude * (3.14159265359 / 180);
    final double deltaLatRad =
        (other.latitude - latitude) * (3.14159265359 / 180);
    final double deltaLngRad =
        (other.longitude - longitude) * (3.14159265359 / 180);

    final double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $formattedAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
