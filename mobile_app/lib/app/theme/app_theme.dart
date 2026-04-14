import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color ivory = Color(0xFFF8F4ED);
  static const Color warmSurface = Color(0xFFFFFCF8);
  static const Color line = Color(0xFFE4D8C8);
  static const Color softGold = Color(0xFFD7B089);
  static const Color bronze = Color(0xFFB88957);
  static const Color deepNavy = Color(0xFF10243E);
  static const Color mutedInk = Color(0xFF5D6776);
  static const Color danger = Color(0xFFB14F45);

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: deepNavy,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDCE5F0),
      onPrimaryContainer: deepNavy,
      secondary: bronze,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF0DEC8),
      onSecondaryContainer: deepNavy,
      tertiary: softGold,
      onTertiary: deepNavy,
      tertiaryContainer: Color(0xFFF7E9D7),
      onTertiaryContainer: deepNavy,
      error: danger,
      onError: Colors.white,
      errorContainer: Color(0xFFF9E2DE),
      onErrorContainer: danger,
      surface: warmSurface,
      onSurface: deepNavy,
      onSurfaceVariant: mutedInk,
      outline: Color(0xFFCDBDAA),
      outlineVariant: line,
      shadow: Color(0x140E1A2B),
      scrim: Color(0x660E1A2B),
      inverseSurface: deepNavy,
      onInverseSurface: warmSurface,
      inversePrimary: softGold,
      surfaceTint: deepNavy,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ivory,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: deepNavy,
            displayColor: deepNavy,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: ivory,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: warmSurface,
        elevation: 0,
        shadowColor: const Color(0x14000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFEFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: deepNavy,
          side: const BorderSide(color: Color(0xFFCDBDAA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: bronze,
        foregroundColor: Colors.white,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: ivory,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.8,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        iconColor: bronze,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF0E3D2),
        selectedColor: const Color(0xFFE7D4BD),
        labelStyle: const TextStyle(
          color: deepNavy,
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
