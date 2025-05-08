import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _nameController = TextEditingController();

  final List<String> _availableDrinks = [
    "Cerveja - Heineken",
    "Cerveja - Brahma",
    "Vodka - Smirnoff",
    "Vodka - Absolut",
    "Rum - Bacardi",''
    "Rum - Havana Club",
    "Gin - Tanqueray",
    "Gin - Beefeater",
    "Tequila - José Cuervo",
    "Tequila - Don Julio",
    "Cachaça - 51",
    "Whisky - Johnnie Walker",
    "Whisky - Jack Daniel’s",
    "Energético - Red Bull",
    "Energético - Monster",
    "Energético - TNT",
    "Energético - Fusion",
  ];

  final List<String> _selectedDrinks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text("Criar Orçamento", style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins')),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome do Orçamento",
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
            Text("Selecione os Drinks:",
                style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
            Expanded(
              child: ListView.builder(
                itemCount: _availableDrinks.length,
                itemBuilder: (context, index) {
                  final drink = _availableDrinks[index];
                  return CheckboxListTile(
                    title: Text(drink, style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins')),
                    checkColor: Colors.black,
                    activeColor: Color(0xFFD0A74C),
                    value: _selectedDrinks.contains(drink),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedDrinks.add(drink);
                        } else {
                          _selectedDrinks.remove(drink);
                        }
                      });
                    },
                  );
                },
              ),
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
              onPressed: () {
                if (_nameController.text.isNotEmpty && _selectedDrinks.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Orçamento '${_nameController.text}' criado!")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha todos os campos!")),
                  );
                }
              },
              child: Text("Salvar Orçamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}
