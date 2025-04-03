import 'package:flutter/material.dart';
import 'BudgetScreen.dart';
import 'PreMadeBudgetsScreen.dart';
import 'LoginScreen.dart';  

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Bem-vindo",
          style: TextStyle(
            color: Color(0xFFD0A74C),
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Seus botões existentes...
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BudgetScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD0A74C),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  child: Text("Montar Orçamento"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PreMadeBudgetsScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD0A74C),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  child: Text("Ver Orçamentos Pré-montados"),
                ),
              ],
            ),
          ),
          // Botão "Sair da conta" posicionado no canto inferior esquerdo
          Positioned(
            left: 16,
            bottom: 16,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                "Sair da conta",
                style: TextStyle(
                  color: Color(0xFFD0A74C),
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}