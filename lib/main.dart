import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/home_screen.dart'; // Sesuaikan path-nya ya Bro

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Memuat file .env
  await dotenv.load(fileName: ".env");

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [Devices.ios.iPhone11ProMax, Devices.ios.iPadPro11Inches],
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'AI Schedule Generator',

      // --- TEMA GLOBAL DIUPDATE KE HIJAU MODERN ---
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981), // Emerald Green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF4F9F4,
        ), // Putih kehijauan soft
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10B981), // Appbar bawaan hijau
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
