import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LivroReceitasApp());
}

class LivroReceitasApp extends StatefulWidget {
  const LivroReceitasApp({super.key});

  @override
  State<LivroReceitasApp> createState() =>
      _LivroReceitasAppState();
}

class _LivroReceitasAppState extends State<LivroReceitasApp> {
  ThemeMode tema = ThemeMode.system;

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  void alternarTema() {
    setState(() {
      tema = tema == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    const creme = Color(0xFFFFF8F0);
    const marrom = Color.fromARGB(255, 212, 164, 216);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Livro de Receitas',
      themeMode: tema,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: marrom,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: creme,
        appBarTheme: const AppBarTheme(
          backgroundColor: creme,
          foregroundColor: Color.fromARGB(255, 209, 182, 229),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD9A778),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: SplashScreen(
        onFinish: () {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                tema: tema,
                onAlternarTema: alternarTema,
              ),
            ),
          );
        },
      ),
    );
  }
}

