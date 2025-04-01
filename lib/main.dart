import 'package:flutter/material.dart';
import 'LoginScreen.dart';

void main() {
  runApp(DrinkApp());
}

class DrinkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
