import 'package:flutter/material.dart';
import 'login_page.dart';
import 'utils/theme.dart';
import 'utils/transitions.dart';
import 'utils/scroll_behavior.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      scrollBehavior: CustomScrollBehavior(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return CustomPageRoute(child: const LoginPage());
          default:
            return CustomPageRoute(child: const LoginPage());
        }
      },
    );
  }
}
