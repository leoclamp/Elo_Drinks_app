import 'package:flutter/material.dart';

class PreMadeBudgetsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> preMadeBudgets = [
    {"name": "Festa da Cerveja", "drinks": ["Heineken", "Brahma", "Budweiser"], "price": 100.00},
    {"name": "Noite da Vodka", "drinks": ["Smirnoff", "Absolut", "Grey Goose"], "price": 120.00},
    {"name": "Ritmo do Rum", "drinks": ["Bacardi", "Havana Club", "Captain Morgan"], "price": 130.00},
    {"name": "Giro do Gin", "drinks": ["Tanqueray", "Beefeater", "Bombay Sapphire"], "price": 140.00},
    {"name": "Tequila Party", "drinks": ["José Cuervo", "Don Julio", "Patrón"], "price": 110.00},
    {"name": "Clássicos de Bar", "drinks": ["Whiskey Sour", "Old Fashioned", "Negroni"], "price": 150.00},
    {"name": "Caipirinha & Cia", "drinks": ["Cachaça 51", "Cachaça Ypióca", "Cachaça Velho Barreiro"], "price": 90.00},
    {"name": "Caipirinha de Limão", "drinks": ["Cachaça 51", "Limão", "Açúcar"], "price": 80.00},
    {"name": "Gin Tônica", "drinks": ["Gin Tanqueray", "Água Tônica", "Limão"], "price": 120.00},
    {"name": "Festa do Mojito", "drinks": ["Rum", "Hortelã", "Limão", "Açúcar", "Água com gás"], "price": 100.00},
    {"name": "Screwdriver", "drinks": ["Vodka", "Suco de Laranja"], "price": 95.00},
    {"name": "Margarita", "drinks": ["Tequila", "Triple Sec", "Limão"], "price": 110.00},
    {"name": "Daiquiri", "drinks": ["Rum", "Suco de Limão", "Açúcar"], "price": 105.00},
    {"name": "Piña Colada", "drinks": ["Rum", "Leite de Coco", "Abacaxi"], "price": 120.00},
    {"name": "Moscow Mule", "drinks": ["Vodka", "Ginger Beer", "Limão"], "price": 125.00},
    {"name": "Mai Tai", "drinks": ["Rum", "Amaretto", "Suco de Limão", "Laranja"], "price": 135.00},
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
