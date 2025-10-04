import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'data/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tenta inicializar com opções geradas (recomendado para web e multiplataforma)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Se falhar, tenta inicializar sem opções (fallback) e loga o erro.
    // Mantemos o app rodando para evitar tela branca na apresentação.
    print('Firebase.initializeApp() com opções falhou: $e');
    try {
      await Firebase.initializeApp();eee
    } catch (e2) {
      print('Firebase.initializeApp() fallback falhou: $e2');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passa a Bola',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primarySwatch: Colors.deepPurple,
        primaryColor: KConstants.primaryColor,
        scaffoldBackgroundColor: KConstants.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: KConstants.primaryColor,
          foregroundColor: KConstants.textLightColor,
          titleTextStyle: KTextStyle.titleText.copyWith(
            color: KConstants.textLightColor,
            fontSize: KConstants.fontSizeLarge,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: KTextStyle.titleText,
          titleMedium: KTextStyle.subtitleText,
          bodyLarge: KTextStyle.bodyText,
          bodyMedium: KTextStyle.bodySecondaryText,
          labelLarge: KTextStyle.buttonText,
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
