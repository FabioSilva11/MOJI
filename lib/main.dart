import 'package:flutter/material.dart';

import 'features/moji_pet/presentation/moji_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MojiApp());
}

class MojiApp extends StatelessWidget {
  const MojiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOJI Pet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF070B14),
        fontFamily: 'Roboto',
      ),
      home: const MojiHomePage(),
    );
  }
}
