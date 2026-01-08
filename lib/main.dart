import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/views/data/notifiers.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/payment_page.dart';
import 'package:my_app/views/page/report_page.dart';
import 'package:my_app/views/page/settings_page.dart';
import 'package:my_app/views/widget_tree_second.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setHighRefreshRate();
  }

  Future<void> _setHighRefreshRate() async {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      // Fail silently (device may not support it)
      debugPrint('Failed to set high refresh rate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          routes: {
            '/subscriptions': (_) => const HomeScreen(),
            '/payments': (_) => const PaymentScreen(),
            '/reports': (_) => const ReportsScreen(),
            '/settings': (_) => const SettingsScreen(),
          },
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            textTheme: GoogleFonts.lexendTextTheme(),
            primarySwatch: Colors.blueGrey,
          ),
          home: WidgetTreeSecond(),
        );
      },
    );
  }
}
