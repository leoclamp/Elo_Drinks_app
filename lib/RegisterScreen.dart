import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    final url = Uri.parse('http://localhost:8000/cadastro/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': nameController.text.trim(),
        'user_email': emailController.text.trim(),
        'user_password': passwordController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final jsonResp = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonResp['mensagem'] ?? 'Cadastro realizado')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar. Tente novamente.')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060605),
      appBar: AppBar(
        title: const Text(
          "Crie sua conta",
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFD0A74C)),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
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
              style: const TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
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
              style: const TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
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
              style: const TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0A74C),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: registerUser,
              child: const Text(
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
