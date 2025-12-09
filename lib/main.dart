import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:peta_randusari/screen/login_screen.dart';
import 'package:peta_randusari/services/background_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://vqolgcqjdmtqwnqpcidd.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxb2xnY3FqZG10cXducXBjaWRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NjE0NTksImV4cCI6MjA4MDEzNzQ1OX0.NttkdyyIg6CLjvxDEHhgcorz8VMVdp_fl6U0BXJIn5U",
  );

  // Initialize background service
  await BackgroundService.initBackgroundService();
  await BackgroundService.registerBackgroundTasks();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('Current route: ${ModalRoute.of(context)?.settings.name}');
        });
        return child!;
      },
      title: 'Kelurahan Randusari',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
