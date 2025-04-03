import 'package:flutter/material.dart';

class PreMadeBudgetsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> preMadeBudgets = [
    {"name": "Festa Tropical", "drinks": ["Mojito", "Pina Colada"], "price": 100.00},
    {"name": "Noite Mexicana", "drinks": ["Margarita", "Tequila Sunrise"], "price": 120.00},
    {"name": "Clássicos", "drinks": ["Whiskey Sour", "Old Fashioned"], "price": 150.00},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orçamentos Pré-montados", style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF060605),
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      backgroundColor: Color(0xFF060605),
      body: ListView.builder(
        itemCount: preMadeBudgets.length,
        itemBuilder: (context, index) {
          final budget = preMadeBudgets[index];
          return Card(
            color: Colors.black,
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Color(0xFFD0A74C), width: 2),
            ),
            child: ListTile(
              title: Text(
                budget["name"],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFD0A74C),
                  fontFamily: 'Poppins',
                ),
              ),
              subtitle: Text(
                "Drinks: ${budget["drinks"].join(", ")}",
                style: TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
              ),
              trailing: Text(
                "R\$${budget["price"].toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD0A74C),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Orçamento '${budget["name"]}' selecionado!"),
                    backgroundColor: Color(0xFFD0A74C),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}