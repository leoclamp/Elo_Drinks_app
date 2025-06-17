import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomeScreen.dart';
import 'RegisterScreen.dart';

// Provider para manter o user_id
import 'package:provider/provider.dart';
import 'package:app_bebidas/models/UserData.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  Future<void> loginUser() async {
    final url = Uri.parse('http://localhost:8000/login/');

    final data = {
      'user_email': emailController.text.trim(),
      'user_password': senhaController.text.trim(),
    };

    print('Enviando JSON: ${jsonEncode(data)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final userID = jsonResponse['user_id'];

        //if (jsonResponse.containsKey('token')) {
        //  print('Login bem-sucedido. Token: ${jsonResponse['token']}');
          context.read<UserData>().setUserId(userID.toString());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        //} else {
        //  _showErrorDialog('Resposta inesperada do servidor.');
        //}
      } else if (response.statusCode == 401) {
        _showErrorDialog('Email ou senha inválidos.');
      } else {
        _showErrorDialog('Erro no login. Código: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
      _showErrorDialog('Não foi possível conectar ao servidor. Verifique sua conexão ou tente novamente.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80),
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
      ),
    );
  }
}
