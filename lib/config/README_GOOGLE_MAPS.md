# Configuração do Google Maps

Este documento explica como configurar a integração com o Google Maps no aplicativo.

## 1. Obter API Key do Google Maps

### Passo 1: Acessar o Google Cloud Console
1. Acesse [Google Cloud Console](https://console.cloud.google.com/)
2. Faça login com sua conta Google
3. Crie um novo projeto ou selecione um existente

### Passo 2: Ativar APIs Necessárias
1. No menu lateral, vá em "APIs e Serviços" > "Biblioteca"
2. Procure e ative as seguintes APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS** 
   - **Geocoding API**
   - **Places API** (opcional, para busca de lugares)

### Passo 3: Criar Credenciais
1. Vá em "APIs e Serviços" > "Credenciais"
2. Clique em "Criar Credenciais" > "Chave de API"
3. Copie a chave gerada

### Passo 4: Configurar Restrições (Recomendado)
1. Clique na chave criada para editá-la
2. Em "Restrições de aplicativo":
   - **Android**: Adicione o nome do pacote e SHA-1
   - **iOS**: Adicione o ID do pacote
3. Em "Restrições de API": Selecione apenas as APIs necessárias

## 2. Configurar no Aplicativo

### Passo 1: Atualizar API Key
1. Abra o arquivo `lib/config/google_maps_config.dart`
2. Substitua `YOUR_GOOGLE_MAPS_API_KEY_HERE` pela sua API key:

```dart
static const String apiKey = 'SUA_API_KEY_AQUI';
```

### Passo 2: Configurar Android

1. Abra `android/app/src/main/AndroidManifest.xml`
2. Adicione a API key dentro da tag `<application>`:

```xml
<application>
    <!-- ... outras configurações ... -->
    
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="SUA_API_KEY_AQUI"/>
        
    <!-- ... outras configurações ... -->
</application>
```

### Passo 3: Configurar iOS

1. Abra `ios/Runner/AppDelegate.swift`
2. Adicione o import e configure a API key:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("SUA_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Passo 4: Configurar Permissões

#### Android
Adicione em `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

#### iOS
Adicione em `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Este app precisa acessar sua localização para mostrar torneios próximos.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Este app precisa acessar sua localização para mostrar torneios próximos.</string>
```

## 3. Testando a Configuração

1. Execute o aplicativo
2. Navegue até a página de criação de campeonatos
3. Teste o seletor de localização
4. Verifique se o mapa carrega corretamente
5. Teste a busca de endereços

## 4. Funcionalidades Implementadas

### Modelos de Dados
- **LocationData**: Modelo para armazenar coordenadas e endereço
- **Championship**: Atualizado para incluir `locationData`

### Serviços
- **LocationService**: Gerencia permissões e busca de localização
- **AnnouncementService**: Já existente

### Widgets
- **LocationPickerWidget**: Seletor de localização com mapa
- **ChampionshipLocationPage**: Exibição da localização do campeonato

### Páginas
- **ChampionshipCreateWithLocationPage**: Exemplo de integração
- **ChampionshipLocationPage**: Visualização da localização

## 5. Próximos Passos

1. Integrar o seletor de localização na página de criação de campeonatos existente
2. Adicionar botão "Ver no Mapa" nos cards de campeonatos
3. Implementar busca de campeonatos por proximidade
4. Adicionar navegação para o app de mapas nativo

## 6. Solução de Problemas

### Mapa não carrega
- Verifique se a API key está correta
- Confirme se as APIs estão ativadas
- Verifique as restrições de aplicativo

### Erro de permissão
- Verifique se as permissões estão configuradas
- Teste em dispositivo físico (não emulador)

### Busca de endereços não funciona
- Verifique se a Geocoding API está ativada
- Confirme se a API key tem acesso à API

## 7. Custos

- **Maps SDK**: Gratuito até 28.000 carregamentos de mapa por mês
- **Geocoding API**: Gratuito até 40.000 requisições por mês
- **Places API**: Pago conforme uso

Consulte a [página de preços](https://cloud.google.com/maps-platform/pricing) para mais detalhes.
