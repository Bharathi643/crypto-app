import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/crypto_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/device_service.dart';
import 'services/realtime_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final deviceId = await DeviceService().getDeviceId();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CryptoProvider(
        api: ApiService(),
        realtime: RealtimeService(),
        deviceId: deviceId,
      )..initialize(),
      child: const CryptoApp(),
    ),
  );
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF040C16);
    const surface = Color(0xFF091622);
    const primary = Color(0xFF19A9FF);
    const gold = Color(0xFFFFC83D);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          surface: surface,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF07111D),
          indicatorColor: primary.withOpacity(.18),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0C1B2A),
          hintStyle: TextStyle(color: Colors.white.withOpacity(.46)),
          prefixIconColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white.withOpacity(.06)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primary, width: 1.2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF15263A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
