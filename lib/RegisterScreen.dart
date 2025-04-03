import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605), // Fundo preto
      appBar: AppBar(
        title: Text(
          "Crie sua conta",
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFD0A74C)),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)), // Ícone voltar dourado
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome
            TextField(
              decoration: InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)), // Borda dourada
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD0A74C)), // Mesma borda ao focar
                ),
              ),
              style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
            ),
            SizedBox(height: 10),

            // Email
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

            // Senha
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

            // Botão de Cadastro estilizado
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD0A74C), // Dourado
                foregroundColor: Colors.black, // Texto preto
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Cantos arredondados
                ),
              ),
              onPressed: () {
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
