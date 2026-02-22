import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:couldai_user_app/core/theme/app_theme.dart';
import 'package:couldai_user_app/presentation/screens/login_screen.dart';
import 'package:couldai_user_app/presentation/screens/dashboard_screen.dart';
import 'package:couldai_user_app/data/database/app_database.dart';
import 'package:couldai_user_app/core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar base de datos local (SQLite)
  final database = AppDatabase();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        ChangeNotifierProvider(create: (_) => AuthService(database)),
      ],
      child: const RiasApp(),
    ),
  );
}

class RiasApp extends StatelessWidget {
  const RiasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RIAS Desktop Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
