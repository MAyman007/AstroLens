import 'package:flutter/material.dart';
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
