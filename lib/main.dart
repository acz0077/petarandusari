import 'package:flutter/material.dart';
import 'package:peta_randusari/screen/home_screen.dart';
import 'package:peta_randusari/screen/login_screen.dart';
import 'package:peta_randusari/screen/sign_up_screen.dart';
import 'package:peta_randusari/screen/village_maps_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://vqolgcqjdmtqwnqpcidd.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxb2xnY3FqZG10cXducXBjaWRkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1NjE0NTksImV4cCI6MjA4MDEzNzQ1OX0.NttkdyyIg6CLjvxDEHhgcorz8VMVdp_fl6U0BXJIn5U",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/sign_up': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/image': (context) => const VillageMapsScreen(),
        '/village_maps': (context) => const VillageMapsScreen(),
        '/resident_table': (context) => const HomeScreen(),
        '/display_image': (context) => Scaffold(
          appBar: AppBar(title: Text('Tampilkan Gambar')),
          body: Center(
            child: Image.asset(
              'assets/images/petarandusari1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Text('Gambar tidak ditemukan');
              },
            ),
          ),
        ),
      },
    );
  }
}
