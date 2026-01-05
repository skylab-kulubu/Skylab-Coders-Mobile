import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/providers/data_provider.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const SkylabCodersApp());
}

class SkylabCodersApp extends StatelessWidget {
  const SkylabCodersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: MaterialApp(
        title: 'SkyLab Coders',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
            background: AppColors.background,
            surface: AppColors.surface,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ).apply(
            bodyColor: AppColors.slate300,
            displayColor: AppColors.slate50,
          ),
          // cardTheme: Removed to avoid type issues, custom widgets handle styling.
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.outfit(
              color: AppColors.slate50,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
