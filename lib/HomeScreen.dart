import 'package:flutter/material.dart';
import 'BudgetScreen.dart';
import 'PreMadeBudgetsScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bem-vindo")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetScreen()),
                );
              },
              child: Text("Montar Orçamento"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreMadeBudgetsScreen()),
                );
              },
              child: Text("Ver Orçamentos Pré-montados"),
            ),
          ],
        ),
      ),
    );
  }
}
