import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/financial_manager.dart';
import 'screens/login_screen.dart';

void main() {
  // Pastikan binding diinisialisasi sebelum mengakses platform services (seperti database)
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(
    // Daftarkan FinancialManager sebagai top-level Provider
    ChangeNotifierProvider(
      create: (context) => FinancialManager(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Findana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        )
      ),
      home: const LoginScreen(),
    );
  }
}