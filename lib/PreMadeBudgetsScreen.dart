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
      appBar: AppBar(title: Text("Orçamentos Pré-montados")),
      body: ListView.builder(
        itemCount: preMadeBudgets.length,
        itemBuilder: (context, index) {
          final budget = preMadeBudgets[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(budget["name"], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Drinks: ${budget["drinks"].join(", ")}"),
              trailing: Text("R\$${budget["price"].toStringAsFixed(2)}"),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Orçamento '${budget["name"]}' selecionado!")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
