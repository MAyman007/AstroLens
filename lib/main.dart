import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const AstroLensApp());
}

class AstroLensApp extends StatelessWidget {
  const AstroLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astro Lens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D4FF), // Cosmic Blue
          secondary: Color(0xFF7C4DFF), // Electric Purple
          tertiary: Color(0xFF00BFA5), // Emerald Teal
          surface: Color(0xFF1A1D29), // Deep Space Blue
          background: Color(0xFF0F1419), // Midnight Black
          onPrimary: Color(0xFF001A20),
          onSecondary: Colors.white,
          onTertiary: Color(0xFF002020),
          onSurface: Color(0xFFE1E3E8),
          onBackground: Color(0xFFBFC2C7),
          surfaceVariant: Color(0xFF242938),
          onSurfaceVariant: Color(0xFFBFC2C7),
          outline: Color(0xFF3D4354),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              headlineLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headlineMedium: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1A1D29),
          foregroundColor: const Color(0xFFE1E3E8),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE1E3E8),
          ),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF242938),
          elevation: 8,
          surfaceTintColor: Colors.transparent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D4FF),
            foregroundColor: const Color(0xFF001A20),
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            elevation: 4,
            shadowColor: const Color(0xFF00D4FF).withOpacity(0.3),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF7C4DFF).withOpacity(0.15),
          labelStyle: const TextStyle(color: Color(0xFFE1E3E8)),
          side: BorderSide(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
          selectedColor: const Color(0xFF7C4DFF).withOpacity(0.3),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
