import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'data/constants.dart';

void main() {
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
