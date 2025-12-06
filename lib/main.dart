import 'package:flutter/material.dart';
import 'package:peta_randusari/screen/home_screen.dart';
import 'package:peta_randusari/screen/login_screen.dart';
import 'package:peta_randusari/screen/sign_up_screen.dart';
import 'package:peta_randusari/screen/maps_randusari_screen.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SupabaseService()),
      ],
      child: MaterialApp(
        title: 'Kelurahan Randusari',
        theme: ThemeData(
          primaryColor: Colors.blue[900],
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.blue[700],
          ),
          fontFamily: 'Roboto',
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[900],
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/signup': (context) => SignUpScreen(),
          '/maps': (context) => MapsRandusariScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}