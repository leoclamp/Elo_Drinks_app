import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BudgetLaborScreen extends StatefulWidget {
  @override
  _BudgetLaborScreenState createState() => _BudgetLaborScreenState();
}

class _BudgetLaborScreenState extends State<BudgetLaborScreen> {
  // Variáveis mão de obra
  final double pricePerHour = 10.0;
  int bartenderCount = 0;
  int waiterCount = 0;
  int hours = 0;

  // Variáveis drinks
  final TextEditingController _nameController = TextEditingController();
  final List<String> _availableDrinks = [
    "Cerveja - Heineken",
    "Cerveja - Brahma",
    "Vodka - Smirnoff",
    "Vodka - Absolut",
    "Rum - Bacardi",
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

  double get totalLaborPrice => (bartenderCount + waiterCount) * hours * pricePerHour;

  double get totalPrice {
    // Se quiser somar preço dos drinks, precisa ter preço pra cada drink, por enquanto só mão de obra
    return totalLaborPrice;
  }

  Future<void> _enviarOrcamento() async {
    final budget = {
      'nome': _nameController.text,
      'drinksSelecionados': _selectedDrinks,
      'bartenders': bartenderCount,
      'garcons': waiterCount,
      'horas': hours,
      'precoTotalMaoDeObra': totalLaborPrice,
    };

    final jsonBudget = jsonEncode(budget);
    print("JSON a ser enviado: $jsonBudget");

    try {
      final response = await http.post(
        Uri.parse('https://localhost:8000/budget'), // ajuste URL real aqui
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBudget,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Orçamento enviado com sucesso!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar orçamento: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text("Orçamento e Mão de Obra", style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins')),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome orçamento
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

            // Controles mão de obra
            Text("Mão de Obra", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            SizedBox(height: 10),

            _buildCounter("Bartender", bartenderCount, () {
              if (bartenderCount > 0) setState(() => bartenderCount--);
            }, () {
              setState(() => bartenderCount++);
            }),

            SizedBox(height: 10),

            _buildCounter("Garçom", waiterCount, () {
              if (waiterCount > 0) setState(() => waiterCount--);
            }, () {
              setState(() => waiterCount++);
            }),

            SizedBox(height: 10),

            _buildCounter("Horas", hours, () {
              if (hours > 0) setState(() => hours--);
            }, () {
              setState(() => hours++);
            }),

            SizedBox(height: 20),
            Text("Preço Total Mão de Obra: R\$${totalLaborPrice.toStringAsFixed(2)}",
                style: TextStyle(color: Color(0xFFD0A74C), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),

            SizedBox(height: 20),

            // Seleção de Drinks
            Text("Selecione os Drinks:", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
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

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD0A74C),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              onPressed: () {
                if (_nameController.text.isEmpty || (bartenderCount == 0 && waiterCount == 0) || hours == 0 || _selectedDrinks.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preencha todos os campos e selecione pelo menos um drink e mão de obra!")),
                  );
                  return;
                }
                _enviarOrcamento();
              },
              child: Text("Salvar Orçamento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int value, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove, color: Color(0xFFD0A74C)), onPressed: onDecrement),
            Text("$value", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
            IconButton(icon: Icon(Icons.add, color: Color(0xFFD0A74C)), onPressed: onIncrement),
            if (label != "Horas")
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Preço por hora: R\$${pricePerHour.toStringAsFixed(2)}", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 14, fontFamily: 'Poppins')),
              ),
          ],
        ),
      ],
    );
  }
}
