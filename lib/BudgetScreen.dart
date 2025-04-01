import 'package:flutter/material.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedDrinks = [];
  final List<String> _availableDrinks = ["Mojito", "Margarita", "Long Island", "Pina Colada"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Criar Orçamento")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Nome do Orçamento",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Selecione os Drinks:"),
            Expanded(
              child: ListView.builder(
                itemCount: _availableDrinks.length,
                itemBuilder: (context, index) {
                  final drink = _availableDrinks[index];
                  return CheckboxListTile(
                    title: Text(drink),
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
              child: Text("Salvar Orçamento"),
            ),
          ],
        ),
      ),
    );
  }
}
