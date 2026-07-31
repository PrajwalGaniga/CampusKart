import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — indigo/violet
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4B44CC);

  // Accent — soft pink
  static const Color accent = Color(0xFFFF6584);

  // Surface / Background
  static const Color background = Color(0xFFF4F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EFFE);

  // Status colours
  static const Color success = Color(0xFF4CAF82);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF5C7A);

  // Text
  static const Color textPrimary = Color(0xFF1A1446);
  static const Color textSecondary = Color(0xFF6B6B8A);
  static const Color textHint = Color(0xFFAAAAAA);

  // Category badge colours
  static const Color catAcademic = Color(0xFF6C63FF);
  static const Color catFood = Color(0xFFFF9A3C);
  static const Color catTransport = Color(0xFF3CC8FF);
  static const Color catEmergency = Color(0xFFFF5C7A);
  static const Color catItems = Color(0xFF43D9AD);
  static const Color catLocation = Color(0xFFFFB347);
  static const Color catEvent = Color(0xFFBB6BD9);
  static const Color catOther = Color(0xFF9AA5B4);
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    const seedColor = AppColors.primary;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: EdgeInsets.zero,
        shadowColor: Color(0x14000000),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
      ),

      // Bottom navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
        elevation: 0,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Tab bar
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEF5),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

/// Helper: gradient card decoration with soft shadow
BoxDecoration cardDecoration({
  double radius = 16,
  Color color = AppColors.surface,
  List<BoxShadow>? shadow,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: shadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
  );
}

/// Helper: primary gradient decoration
BoxDecoration primaryGradientDecoration({double radius = 16}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      colors: [AppColors.primary, AppColors.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

/// Returns a category colour
Color categoryColor(String category) {
  switch (category.toUpperCase()) {
    case 'ACADEMIC':
      return AppColors.catAcademic;
    case 'FOOD':
      return AppColors.catFood;
    case 'TRANSPORT':
      return AppColors.catTransport;
    case 'EMERGENCY':
      return AppColors.catEmergency;
    case 'ITEMS':
      return AppColors.catItems;
    case 'LOCATION':
      return AppColors.catLocation;
    case 'EVENT':
      return AppColors.catEvent;
    default:
      return AppColors.catOther;
  }
}

/// Returns a category icon
IconData categoryIcon(String category) {
  switch (category.toUpperCase()) {
    case 'ACADEMIC':
      return Icons.school_rounded;
    case 'FOOD':
      return Icons.restaurant_rounded;
    case 'TRANSPORT':
      return Icons.directions_bus_rounded;
    case 'EMERGENCY':
      return Icons.emergency_rounded;
    case 'ITEMS':
      return Icons.shopping_bag_rounded;
    case 'LOCATION':
      return Icons.place_rounded;
    case 'EVENT':
      return Icons.event_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}
