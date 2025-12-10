import 'package:flutter/material.dart';

/// Tema de la aplicación de barbería
class AppTheme {
  AppTheme._();

  // Colores principales - Barbería moderna y profesional
  static const Color primaryColor = Color(0xFF1A1A2E); // Azul oscuro elegante
  static const Color secondaryColor = Color(0xFFD4AF37); // Dorado barbería
  static const Color accentColor = Color(0xFF16213E); // Azul profundo
  static const Color errorColor = Color(0xFFE94560); // Rojo suave
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // Colores adicionales para barbería
  static const Color barberGold = Color(0xFFD4AF37);
  static const Color barberDarkBlue = Color(0xFF1A1A2E);
  static const Color barberLightBlue = Color(0xFF0F3460);
  static const Color barberGrey = Color(0xFF6C757D);

  // Tema claro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: primaryColor,
        onSurface: primaryColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar con estilo premium de barbería
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: barberGold,
        titleTextStyle: TextStyle(
          color: barberGold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(
          color: barberGold,
        ),
      ),
      
      // Cards con diseño elegante
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black26,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
      
      // Input fields con diseño moderno
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: barberGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: TextStyle(color: barberGrey),
        prefixIconColor: barberGrey,
      ),
      
      // Botones con estilo premium
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: barberGold,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botones outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: barberGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: barberGold,
        foregroundColor: primaryColor,
        elevation: 4,
      ),
      
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        selectedColor: barberGold,
        secondarySelectedColor: barberGold,
        labelStyle: const TextStyle(color: primaryColor),
        secondaryLabelStyle: const TextStyle(color: primaryColor),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
