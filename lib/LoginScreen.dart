import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomeScreen.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> loginUser() async {
    final url = Uri.parse('https://api.com/login'); // Substitua pela URL real da API

    final data = {
      'user_email': emailController.text,
      'user_password': senhaController.text,
    };

    // JSON que está sendo enviado
    print('Enviando JSON: ${jsonEncode(data)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('Login bem-sucedido: ${response.body}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print('Erro no login: ${response.statusCode}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Erro'),
          content: Text('Email ou senha inválidos.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/Login.png',
                width: 300,
                height: 300,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Bem vindo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD0A74C),
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
              ),
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 10),

            TextField(
              controller: senhaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
              ),
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD0A74C),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: loginUser,
              child: Text(
                "Entrar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFFD0A74C),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Color(0xFFD0A74C), width: 2),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text(
                "Criar uma conta",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
