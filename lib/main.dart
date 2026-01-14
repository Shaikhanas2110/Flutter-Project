import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';
import 'package:my_app/lock_screen.dart';
import 'package:my_app/views/data/classes/theme_provider.dart';
import 'package:my_app/views/page/home_page.dart';
import 'package:my_app/views/page/payment_page.dart';
import 'package:my_app/views/page/report_page.dart';
import 'package:my_app/views/page/settings_page.dart';
import 'package:my_app/views/widget_tree_second.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    AppLock(
      initialBackgroundLockLatency: const Duration(seconds: 0),
      lockScreen: LockScreen(),
      builder: (context, child) {
        return ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
          child: const MyApp(),
        );
      },
    ),
  );
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
      debugPrint('Failed to set high refresh rate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      routes: {
        '/subscriptions': (_) => const HomeScreen(),
        '/payments': (_) => const PaymentScreen(),
        '/reports': (_) => const ReportsScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          AppLock.of(context)?.disable();
          return const WidgetTreeSecond();
        }

        AppLock.of(context)?.enable();
        return const HomeScreen();
      },
    );
  }
}
