class GoogleMapsConfig {
  // Substitua pela sua API key do Google Maps
  // Para obter uma API key:
  // 1. Acesse https://console.cloud.google.com/
  // 2. Crie um projeto ou selecione um existente
  // 3. Ative a API "Maps SDK for Android" e "Maps SDK for iOS"
  // 4. Crie credenciais (API Key)
  // 5. Configure restrições de aplicativo (Android/iOS)

  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // Verifica se a API key foi configurada
  static bool get isConfigured => apiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  // Retorna a API key ou lança uma exceção se não configurada
  static String getApiKey() {
    if (!isConfigured) {
      throw Exception(
        'Google Maps API key não configurada. '
        'Configure a API key em lib/config/google_maps_config.dart',
      );
    }
    return apiKey;
  }
}
