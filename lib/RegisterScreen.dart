import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  Future<void> registerUser() async {
    final url = Uri.parse('http://localhost:8000/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': 'João',
        'user_email': 'dasd@gmail.com',
        'user_password': '123',
      }),
    );

    if (response.statusCode == 200) {
      print('Resposta da API: ${response.body}');
    } else {
      print('Erro: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text(
          "Crie sua conta",
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFD0A74C)),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)), 
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)), 
                ),
              ),
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
              ),
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD0A74C),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), 
                ),
              ),
              onPressed: () {
                registerUser();
                Navigator.pop(context);
              },
              child: Text(
                "Cadastrar",
                style: TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}