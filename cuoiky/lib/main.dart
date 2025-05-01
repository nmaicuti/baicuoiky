import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuoiky/task_manager/providers/auth_provider.dart';
import 'package:cuoiky/task_manager/providers/task_provider.dart';
import 'package:cuoiky/task_manager/providers/theme_provider.dart';
import 'package:cuoiky/task_manager/screens/login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Task Manager',
            theme: themeProvider.themeData,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}