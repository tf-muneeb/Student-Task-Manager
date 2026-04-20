import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/view_tasks_screen.dart';
import 'screens/edit_task_screen.dart';
import 'models/task_model.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';

final ValueNotifier<ThemeMode> themeNotifier =
ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, mode, __) => StudentTaskManagerApp(themeMode: mode),
      ),
    ),
  );
}

class StudentTaskManagerApp extends StatelessWidget {
  final ThemeMode themeMode;
  const StudentTaskManagerApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/add-task':
            return MaterialPageRoute(builder: (_) => const AddTaskScreen());
          case '/view-tasks':
            return MaterialPageRoute(builder: (_) => const ViewTasksScreen());
          case '/edit-task':
            final task = settings.arguments as TaskModel;
            return MaterialPageRoute(
                builder: (_) => EditTaskScreen(task: task));
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    final cardColor = isDark ? const Color(0xFF16213E) : Colors.white;
    final scaffoldColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0F4FF);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90D9),
        brightness: brightness,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor:
        isDark ? const Color(0xFF16213E) : const Color(0xFF4A90D9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
        titleSmall: TextStyle(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90D9),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF16213E) : Colors.grey.shade50,
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF4A90D9), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black12,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}