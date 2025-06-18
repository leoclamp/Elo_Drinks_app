import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // para FilteringTextInputFormatter
import 'package:app_bebidas/models/UserData.dart';

// Modelos
class Drink {
  final int id;
  final String type;
  final String name;
  final double? pricePerLiter;

  Drink({
    required this.id,
    required this.type,
    required this.name,
    this.pricePerLiter,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(
      id: json['drink_id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      pricePerLiter: json.containsKey('price_per_liter')
          ? (json['price_per_liter'] is num
              ? (json['price_per_liter'] as num).toDouble()
              : double.tryParse(json['price_per_liter'].toString()))
          : null,
    );
  }
}

class Labor {
  final int id;
  final String type;
  final double pricePerHour;

  Labor({
    required this.id,
    required this.type,
    required this.pricePerHour,
  });

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      id: json['labor_id'] as int,
      type: json['type'] as String,
      pricePerHour: (json['price_per_hour'] is num
          ? (json['price_per_hour'] as num).toDouble()
          : double.tryParse(json['price_per_hour'].toString()) ?? 0.0),
    );
  }
}

// Widget principal
class BudgetLaborScreen extends StatefulWidget {
  @override
  _BudgetLaborScreenState createState() => _BudgetLaborScreenState();
}

class _BudgetLaborScreenState extends State<BudgetLaborScreen> {
  final TextEditingController _nameController = TextEditingController();

  List<Drink> _availableDrinks = [];
  List<Labor> _availableLabors = [];
  Map<int, int> _laborCounts = {}; // labor_id -> quantidade
  Set<int> _selectedDrinkIds = {}; // drink_id selecionados
  Map<int, TextEditingController> _drinkQuantityControllers = {}; // drink_id -> controller
  Map<int, int> _drinkQuantities = {}; // drink_id -> quantidade

  int _hours = 0;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Ajuste a URL para seu endpoint que retorna JSON com arrays "drinks" e "labor"
      final uri = Uri.parse('http://localhost:8000/budget_labor/');
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final drinksJson = data['drinks'] as List<dynamic>;
        final laborsJson = data['labor'] as List<dynamic>;
        final drinks = drinksJson
            .map((e) => Drink.fromJson(e as Map<String, dynamic>))
            .toList();
        final labors = laborsJson
            .map((e) => Labor.fromJson(e as Map<String, dynamic>))
            .toList();

        // Inicializa contadores de labor, mantendo valores antigos se existirem
        final Map<int,int> laborCountsInit = {};
        for (var labor in labors) {
          laborCountsInit[labor.id] = _laborCounts[labor.id] ?? 0;
        }

        // Inicializa controllers de quantidade de drinks, mantendo valores antigos se houver
        final Map<int, TextEditingController> drinkCtrlsInit = {};
        final Map<int, int> drinkQtysInit = {};
        for (var drink in drinks) {
          final prevQty = _drinkQuantities[drink.id] ?? 0;
          final controller = TextEditingController(text: prevQty.toString());
          drinkCtrlsInit[drink.id] = controller;
          drinkQtysInit[drink.id] = prevQty;
        }

        setState(() {
          _availableDrinks = drinks;
          _availableLabors = labors;
          _laborCounts = laborCountsInit;
          _drinkQuantityControllers = drinkCtrlsInit;
          _drinkQuantities = drinkQtysInit;
          _isLoading = false;
        });

        // Após setState, adiciona listeners para cada controller de quantidade
        // para capturar mudanças diretas no texto e atualizar totals em tempo real.
        for (var entry in _drinkQuantityControllers.entries) {
          entry.value.addListener(() {
            final text = entry.value.text;
            final parsed = int.tryParse(text) ?? 0;
            if (_drinkQuantities[entry.key] != parsed) {
              setState(() {
                _drinkQuantities[entry.key] = parsed;
              });
            }
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Erro ao buscar dados: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão: $e';
        _isLoading = false;
      });
    }
  }

  double get totalLaborPrice {
    double sum = 0;
    for (var labor in _availableLabors) {
      final cnt = _laborCounts[labor.id] ?? 0;
      if (cnt > 0) sum += cnt * _hours * labor.pricePerHour;
    }
    return sum;
  }

  double get totalDrinksPrice {
    double sum = 0;
    for (var drink in _availableDrinks) {
      final qty = _drinkQuantities[drink.id] ?? 0;
      if (_selectedDrinkIds.contains(drink.id) && drink.pricePerLiter != null && qty > 0) {
        sum += drink.pricePerLiter! * qty;
      }
    }
    return sum;
  }

  double get totalPrice => totalLaborPrice + totalDrinksPrice;

  Future<void> _enviarOrcamento() async {
    final selectedDrinksList = _availableDrinks
        .where((d) => _selectedDrinkIds.contains(d.id) && (_drinkQuantities[d.id] ?? 0) > 0)
        .map((d) => {
              'drink_id': d.id,
              'quantity': _drinkQuantities[d.id],
            })
        .toList();
    final laborList = _availableLabors
        .where((l) => (_laborCounts[l.id] ?? 0) > 0)
        .map((l) => {
              'labor_id': l.id,
              'quantity': _laborCounts[l.id],
            })
        .toList();
    final budget = {
      'user_id': context.read<UserData>().userId,
      'name': _nameController.text,
      'drinks': selectedDrinksList,
      'labors': laborList,
      'hours': _hours,
    };
    final jsonBudget = jsonEncode(budget);
    //print("JSON a ser enviado: $jsonBudget");
    try {
      // Ajuste URL de POST conforme seu backend
      final response = await http.post(
        Uri.parse('http://localhost:8000/budget_labor/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBudget,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Orçamento enviado com sucesso!")),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao enviar orçamento: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro de conexão: $e")),
      );
    }
  }

  Widget _buildCounterHoras() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Horas", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: Color(0xFFD0A74C)),
              onPressed: () {
                if (_hours > 0) {
                  setState(() => _hours--);
                }
              },
            ),
            Text("$_hours", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
            IconButton(
              icon: Icon(Icons.add, color: Color(0xFFD0A74C)),
              onPressed: () {
                setState(() => _hours++);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLaborCounter(Labor labor) {
    final count = _laborCounts[labor.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(labor.type, style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Color(0xFFD0A74C)),
                onPressed: () {
                  if (count > 0) {
                    setState(() {
                      _laborCounts[labor.id] = count - 1;
                    });
                  }
                },
              ),
              Text("$count", style: TextStyle(color: Color(0xFFD0A74C), fontSize: 18, fontFamily: 'Poppins')),
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFFD0A74C)),
                onPressed: () {
                  setState(() {
                    _laborCounts[labor.id] = count + 1;
                  });
                },
              ),
              SizedBox(width: 8),
              Text("R\$${labor.pricePerHour.toStringAsFixed(2)}/h",
                  style: TextStyle(color: Color(0xFFD0A74C), fontSize: 14, fontFamily: 'Poppins')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text("Orçamento e Mão de Obra",
            style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins')),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: Color(0xFFD0A74C)))
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                    ElevatedButton(onPressed: _fetchData, child: Text("Tentar novamente")),
                  ],
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome do orçamento
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Nome do Orçamento",
                          labelStyle:
                              TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFD0A74C)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFD0A74C)),
                          ),
                        ),
                        style:
                            TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 20),

                      // Horas
                      _buildCounterHoras(),
                      SizedBox(height: 20),

                      // Mão de obra
                      Text("Mão de Obra",
                          style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 10),
                      ..._availableLabors.map((l) => _buildLaborCounter(l)).toList(),
                      SizedBox(height: 20),
                      Text("Preço Total Mão de Obra: R\$${totalLaborPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 20),

                      // Drinks com quantidade
                      Text("Selecione os Drinks e insira quantidade:",
                          style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontSize: 18,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _availableDrinks.length,
                        itemBuilder: (context, index) {
                          final drink = _availableDrinks[index];
                          final label = "${drink.type} - ${drink.name}"
                              + (drink.pricePerLiter != null
                                  ? " (R\$${drink.pricePerLiter!.toStringAsFixed(2)}/unit)"
                                  : "");
                          final qtyController = _drinkQuantityControllers[drink.id]!;
                          final isSelected = _selectedDrinkIds.contains(drink.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (selected) {
                                    setState(() {
                                      if (selected == true) {
                                        _selectedDrinkIds.add(drink.id);
                                        // controller já existe com texto anterior ou "0"
                                      } else {
                                        _selectedDrinkIds.remove(drink.id);
                                        // ao desmarcar, zera quantidade via controller e estado
                                        _drinkQuantities[drink.id] = 0;
                                        qtyController.text = '0';
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(label,
                                      style: TextStyle(
                                          color: Color(0xFFD0A74C),
                                          fontFamily: 'Poppins')),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: qtyController,
                                    enabled: isSelected,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Color(0xFFD0A74C)),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                    style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins', fontSize: 14),
                                    onChanged: (val) {
                                      // Embora já tenha listener, mantemos onChanged para parse imediato
                                      final parsed = int.tryParse(val) ?? 0;
                                      if (_drinkQuantities[drink.id] != parsed) {
                                        setState(() {
                                          _drinkQuantities[drink.id] = parsed;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      if (_availableDrinks.any((d) => d.pricePerLiter != null))
                        Text("Preço Total Drinks: R\$${totalDrinksPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: Color(0xFFD0A74C),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins')),
                      Text("Preço Total Geral: R\$${totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins')),
                      SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD0A74C),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                        ),
                        onPressed: () {
                          final hasLabor = _laborCounts.values.any((cnt) => cnt > 0);
                          final hasDrinkValid = _selectedDrinkIds.any((id) => (_drinkQuantities[id] ?? 0) > 0);
                          if (_nameController.text.isEmpty ||
                              !hasLabor ||
                              _hours <= 0 ||
                              !hasDrinkValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Preencha todos os campos e selecione pelo menos um drink com quantidade > 0 e mão de obra!")),
                            );
                            return;
                          }
                          _enviarOrcamento();
                        },
                        child: Text("Salvar Orçamento",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins')),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _drinkQuantityControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
}
