import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app_bebidas/models/UserData.dart';

class UserBudgetsScreen extends StatefulWidget {
  final bool? testIsLoading;
  final String? testErrorMessage;
  final List<Map<String, dynamic>>? testBudgets;

  UserBudgetsScreen({
    Key? key,
    this.testIsLoading,
    this.testErrorMessage,
    this.testBudgets,
  }) : super(key: key);

  @override
  _UserBudgetsScreenState createState() => _UserBudgetsScreenState();
}

class _UserBudgetsScreenState extends State<UserBudgetsScreen> {
  List<Map<String, dynamic>> userBudgets = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.testIsLoading != null) {
      isLoading = widget.testIsLoading!;
      errorMessage = widget.testErrorMessage;
      userBudgets = widget.testBudgets ?? [];
    } else {
      fetchUserBudgets();
    }
  }

  Future<void> fetchUserBudgets() async {
    try {
      String? userId = context.read<UserData>().userId;

      final data = {'user_id': userId};
      final response = await http.post(
        Uri.parse('http://localhost:8000/user_budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print(response.body);
        if(response.body.contains('Nenhum item encontrado')){
          setState(() {
            errorMessage = 'Nenhum dado encontrado.';
            isLoading = false;
          });
          return;
        }

        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          userBudgets = data.map<Map<String, dynamic>>((item) {
            // Parse de hours de forma segura
            int totalHours = 0;
            final rawHours = item['hours'];
            if (rawHours != null) {
              if (rawHours is num) {
                totalHours = rawHours.toInt();
              } else {
                totalHours = int.tryParse(rawHours.toString()) ?? 0;
              }
            }
            // Cálculo total de drinks
            double totalDrinksPrice = 0.0;
            final drinksList = (item['drinks'] as List).map<String>((drink) {
              final name = drink['name'];
              final type = drink['type'];
              final quantityNum = drink['quantity'];
              final priceNum = drink['price_per_liter'];
              final quantity = (quantityNum is num)
                  ? quantityNum.toInt()
                  : int.tryParse(quantityNum.toString()) ?? 0;
              final pricePerLiter = (priceNum is num)
                  ? priceNum.toDouble()
                  : double.tryParse(priceNum.toString()) ?? 0.0;
              totalDrinksPrice += quantity * pricePerLiter;
              final precoStr = pricePerLiter.toStringAsFixed(2);
              return '$name ($type) x$quantity - R\$${precoStr}';
            }).toList();

            // Inicializa variáveis de custo de labor e taxa horária
            double totalLaborPrice = 0.0;
            double totalBartenderPrice = 0.0;
            double totalGarconPrice = 0.0;
            double bartenderHourlyRate = 0.0;
            double garconHourlyRate = 0.0;

            // Percorre lista de labor
            for (var l in (item['labor'] as List)) {
              final type = l['type'];
              final quantityNum = l['quantity'];
              final priceNum = l['price_per_hour'];
              final quantity = (quantityNum is num)
                  ? quantityNum.toInt()
                  : int.tryParse(quantityNum.toString()) ?? 0;
              final pricePerHour = (priceNum is num)
                  ? priceNum.toDouble()
                  : double.tryParse(priceNum.toString()) ?? 0.0;

              // Se for o primeiro Bartender, guarda a taxa horária
              if (type == 'Bartender' && bartenderHourlyRate == 0.0) {
                bartenderHourlyRate = pricePerHour;
              }
              // Se for o primeiro Garçom, guarda a taxa horária
              if ((type == 'Garçom' || type.toString().toLowerCase().contains('garçom')) 
                  && garconHourlyRate == 0.0) {
                garconHourlyRate = pricePerHour;
              }

              // Custo acumulado: quantity * pricePerHour * totalHours
              final custo = quantity * pricePerHour * totalHours;
              totalLaborPrice += custo;
              if (type == 'Bartender') {
                totalBartenderPrice += custo;
              } else if (type == 'Garçom' || type.toString().toLowerCase().contains('garçom')) {
                totalGarconPrice += custo;
              }
            }

            // Quantidades de cada tipo
            final totalBartenders = (item['labor'] as List)
                .where((l) => l['type'] == 'Bartender')
                .fold<int>(0, (sum, l) => sum + ((l['quantity'] is num) ? (l['quantity'] as num).toInt() : int.tryParse(l['quantity'].toString()) ?? 0));
            final totalGarcons = (item['labor'] as List)
                .where((l) => l['type'] == 'Garçom')
                .fold<int>(0, (sum, l) => sum + ((l['quantity'] is num) ? (l['quantity'] as num).toInt() : int.tryParse(l['quantity'].toString()) ?? 0));

            return {
              "name": item["name"],
              "hours": totalHours,
              "drinks": drinksList,
              "bartenders": totalBartenders,
              "garcons": totalGarcons,
              "bartenderHourlyRate": bartenderHourlyRate,
              "garconHourlyRate": garconHourlyRate,
              "totalDrinksPrice": totalDrinksPrice,
              "totalLaborPrice": totalLaborPrice,
              "totalBartenderPrice": totalBartenderPrice,
              "totalGarconPrice": totalGarconPrice,
              "totalPrice": totalDrinksPrice + totalLaborPrice,
            };
          }).toList();

          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar orçamentos (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        //print(e);
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text(
          'Meus Orçamentos',
          style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Color(0xFFD0A74C)),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                  ),
                )
              : userBudgets.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum orçamento encontrado.',
                        style: TextStyle(
                          color: Color(0xFFD0A74C),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: userBudgets.length,
                      itemBuilder: (context, index) {
                        final budget = userBudgets[index];
                        final totalDrinks = budget['totalDrinksPrice'] as double;
                        final totalLabor = budget['totalLaborPrice'] as double;
                        final total = budget['totalPrice'] as double;
                        final hours = budget['hours'] as int;
                        final bartenderRate = budget['bartenderHourlyRate'] as double;
                        final garconRate = budget['garconHourlyRate'] as double;

                        return Card(
                          color: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Color(0xFFD0A74C), width: 2),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Horas trabalhadas: $hours",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Drinks:\n ${budget['drinks'].join('\n ')}",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Preço total das bebidas: R\$${totalDrinks.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Bartenders: ${budget['bartenders']}\t - \tR\$${bartenderRate.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  "Garçons: ${budget['garcons']}\t - \tR\$${garconRate.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Preço total dos trabalhadores: R\$${totalLabor.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Divider(color: Color(0xFFD0A74C)),
                                Text(
                                  "Preço total do atendimento: R\$${total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD0A74C),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
