import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int randomNumber = 10000;
  TextEditingController otpController = new TextEditingController();

  @override
  void initState() {
    random();
    super.initState();
  }

  void random() {
    setState(() {
      Random random = new Random();
      randomNumber = random.nextInt(100000);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Verifikasi OTP', style: TextStyle(fontSize: 20)),
            SizedBox(height: 60),
            Text(randomNumber.toString()),
            SizedBox(height: 60),
            OtpTextField(
              clearText: true,
              numberOfFields: 5,
              borderColor: Color(0xFF512DA8),
              showFieldAsBox: true,
              onCodeChanged: (String code) {
                print(code);
              },
              onSubmit: (String verificationCode) {
                if (randomNumber == int.parse(verificationCode)) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Berhasil Verifikasi"),
                        content: Text('Kode benar'),
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Gagal Verifikasi"),
                        content: Text('Kode salah'),
                      );
                    },
                  );
                }

                setState(() {});
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: random,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
