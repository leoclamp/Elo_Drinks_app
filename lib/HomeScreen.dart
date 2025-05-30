import 'package:flutter/material.dart';
import 'PreMadeBudgetsScreen.dart';
import 'LoginScreen.dart';
import 'BudgetLaborScreen.dart';
import 'UserBudgetsScreen.dart';

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
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BudgetLaborScreen()),
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note, color: Colors.black),
                      SizedBox(width: 8),
                      Text("Montar Orçamento + Mão de Obra"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreMadeBudgetsScreen()),
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long, color: Colors.black),
                      SizedBox(width: 8),
                      Text("Ver Orçamentos Pré-montados"),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserBudgetsScreen()),
                  ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_shared, color: Colors.black),
                      SizedBox(width: 8),
                      Text("Ver Meus Orçamentos"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Botão de texto "Sair da conta"
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
