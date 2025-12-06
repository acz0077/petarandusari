// widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peta_randusari/main.dart';
import 'package:peta_randusari/screen/login_screen.dart';
import 'package:peta_randusari/screen/sign_up_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Verify that login screen renders
    expect(find.text('KELURAHAN RANDUSARI'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Sign up screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignUpScreen(),
      ),
    );

    // Verify that sign up screen renders
    expect(find.text('Pendaftaran Akun'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
  });
}