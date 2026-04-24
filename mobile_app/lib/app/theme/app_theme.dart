import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color appBackground = Color(0xFFF7F4EE);
  static const Color surface = Color(0xFFFFFCF7);
  static const Color primaryNavy = Color(0xFF0D2B5B);
  static const Color secondaryNavy = Color(0xFF163A6B);
  static const Color accentGold = Color(0xFFC89A3D);
  static const Color softBeige = Color(0xFFEFE3D1);
  static const Color softBorder = Color(0xFFE7DCCB);
  static const Color textPrimary = Color(0xFF0D2B5B);
  static const Color textSecondary = Color(0xFF5E6675);
  static const Color successSoft = Color(0xFFDDEEDF);
  static const Color infoSoft = Color(0xFFDCE7F8);
  static const Color warningSoft = Color(0xFFF4E6C7);
  static const Color neutralSoft = Color(0xFFE8E5E0);
  static const Color successText = Color(0xFF2F6A46);
  static const Color infoText = Color(0xFF305B8A);
  static const Color warningText = Color(0xFF8A6117);
  static const Color neutralText = Color(0xFF6A645D);
  static const Color error = Color(0xFFB44F43);
  static const Color errorSoft = Color(0xFFF8E2DD);

  static const double pagePadding = 24;
  static const double sectionSpacing = 24;
  static const double cardRadius = 28;
  static const double inputRadius = 22;
  static const double buttonRadius = 20;

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x120D2B5B),
          blurRadius: 22,
          offset: Offset(0, 10),
        ),
      ];

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryNavy,
      onPrimary: surface,
      primaryContainer: Color(0xFFDCE7F8),
      onPrimaryContainer: primaryNavy,
      secondary: secondaryNavy,
      onSecondary: surface,
      secondaryContainer: Color(0xFFE4ECF8),
      onSecondaryContainer: primaryNavy,
      tertiary: accentGold,
      onTertiary: primaryNavy,
      tertiaryContainer: Color(0xFFF4E6C7),
      onTertiaryContainer: primaryNavy,
      error: error,
      onError: Colors.white,
      errorContainer: errorSoft,
      onErrorContainer: error,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: softBorder,
      outlineVariant: softBorder,
      shadow: Color(0x120D2B5B),
      scrim: Color(0x550D2B5B),
      inverseSurface: primaryNavy,
      onInverseSurface: surface,
      inversePrimary: accentGold,
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: appBackground,
      canvasColor: surface,
      splashColor: primaryNavy.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 92,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: softBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: const TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
        ),
        helperStyle: const TextStyle(
          color: textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: softBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: softBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: softBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(
            color: primaryNavy,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(
            color: error,
            width: 1.4,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softBeige,
        selectedColor: warningSoft,
        disabledColor: neutralSoft,
        secondarySelectedColor: warningSoft,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        side: const BorderSide(color: softBorder),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          elevation: 0,
          backgroundColor: primaryNavy,
          foregroundColor: surface,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          elevation: 0,
          foregroundColor: primaryNavy,
          backgroundColor: surface,
          side: const BorderSide(color: softBorder),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryNavy,
        contentTextStyle: const TextStyle(
          color: surface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryNavy,
        foregroundColor: surface,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: softBorder,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: softBorder),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        iconColor: primaryNavy,
        textColor: textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryNavy,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    TextStyle apply(
      TextStyle? style, {
      Color color = textPrimary,
      FontWeight weight = FontWeight.w500,
      double? size,
      double? height,
      double? letterSpacing,
    }) {
      return (style ?? const TextStyle()).copyWith(
        color: color,
        fontWeight: weight,
        fontSize: size,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    return base.copyWith(
      displayLarge: apply(
        base.displayLarge,
        size: 42,
        weight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.1,
      ),
      displayMedium: apply(
        base.displayMedium,
        size: 36,
        weight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -0.8,
      ),
      displaySmall: apply(
        base.displaySmall,
        size: 32,
        weight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -0.6,
      ),
      headlineLarge: apply(
        base.headlineLarge,
        size: 30,
        weight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.5,
      ),
      headlineMedium: apply(
        base.headlineMedium,
        size: 26,
        weight: FontWeight.w700,
        height: 1.14,
        letterSpacing: -0.4,
      ),
      headlineSmall: apply(
        base.headlineSmall,
        size: 22,
        weight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.2,
      ),
      titleLarge: apply(
        base.titleLarge,
        size: 20,
        weight: FontWeight.w700,
        height: 1.2,
      ),
      titleMedium: apply(
        base.titleMedium,
        size: 17,
        weight: FontWeight.w700,
        height: 1.25,
      ),
      titleSmall: apply(
        base.titleSmall,
        size: 15,
        weight: FontWeight.w700,
        height: 1.25,
      ),
      bodyLarge: apply(
        base.bodyLarge,
        size: 17,
        weight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: apply(
        base.bodyMedium,
        size: 15,
        weight: FontWeight.w500,
        height: 1.5,
      ),
      bodySmall: apply(
        base.bodySmall,
        size: 13,
        color: textSecondary,
        weight: FontWeight.w500,
        height: 1.45,
      ),
      labelLarge: apply(
        base.labelLarge,
        size: 14,
        weight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: apply(
        base.labelMedium,
        size: 12,
        color: textSecondary,
        weight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: apply(
        base.labelSmall,
        size: 11,
        color: textSecondary,
        weight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}
