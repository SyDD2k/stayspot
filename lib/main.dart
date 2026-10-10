import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_config.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chatbot.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveTheme();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase(); // Initialize Firebase
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

ThemeData _buildLightTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF6366F1),
      background: Color(0xFFF8FAFC),
      surface: Colors.white,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF1E293B),
      onSurface: Color(0xFF1E293B),
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Color(0xFFF8FAFC),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2563EB),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF2563EB),
        side: BorderSide(color: Color(0xFF2563EB), width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
      ),
      hintStyle: GoogleFonts.poppins(color: Color(0xFF94A3B8)),
      labelStyle: GoogleFonts.poppins(color: Color(0xFF2563EB)),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
      contentTextStyle: GoogleFonts.poppins(fontSize: 16, color: Color(0xFF1E293B)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF2563EB),
      contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

ThemeData _buildDarkTheme() {
  final darkTextTheme = ThemeData.dark().textTheme.copyWith(
    bodyLarge: GoogleFonts.poppins(color: Colors.white),
    bodyMedium: GoogleFonts.poppins(color: Colors.white),
    titleLarge: GoogleFonts.poppins(color: Colors.white),
    titleMedium: GoogleFonts.poppins(color: Colors.white),
    titleSmall: GoogleFonts.poppins(color: Colors.white),
    labelLarge: GoogleFonts.poppins(color: Colors.white),
    bodySmall: GoogleFonts.poppins(color: Colors.white),
    labelSmall: GoogleFonts.poppins(color: Colors.white),
    displayLarge: GoogleFonts.poppins(color: Colors.white),
    displayMedium: GoogleFonts.poppins(color: Colors.white),
    displaySmall: GoogleFonts.poppins(color: Colors.white),
    headlineLarge: GoogleFonts.poppins(color: Colors.white),
    headlineMedium: GoogleFonts.poppins(color: Colors.white),
    headlineSmall: GoogleFonts.poppins(color: Colors.white),
  );

  return ThemeData.dark().copyWith(
    useMaterial3: true,
    textTheme: darkTextTheme,
    primaryTextTheme: darkTextTheme,
    appBarTheme: AppBarTheme(
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: GoogleFonts.poppins(color: Colors.white),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'StaySpot',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
