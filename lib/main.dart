import 'package:flutter/material.dart';
import 'LoginScreen.dart';
import 'package:provider/provider.dart';
import 'package:app_bebidas/models/UserData.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserData()),
      ],
      child: DrinkApp(),
    ),
  );
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
