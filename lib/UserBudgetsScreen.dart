import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app_bebidas/models/UserData.dart';

class UserBudgetsScreen extends StatefulWidget {
  // Estes parâmetros podem ser usados em testes (injeção de valores)
  final bool? testIsLoading;
  final String? testErrorMessage;
  final List<Map<String, dynamic>>? testBudgets;

  const UserBudgetsScreen({
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
      // Ambiente de teste: injeta valores
      isLoading = widget.testIsLoading!;
      errorMessage = widget.testErrorMessage;
      userBudgets = widget.testBudgets ?? [];
    } else {
      fetchUserBudgets();
    }
  }

  Future<void> fetchUserBudgets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      String? userId = context.read<UserData>().userId;
      if (userId == null) {
        setState(() {
          errorMessage = 'Usuário não autenticado.';
          isLoading = false;
        });
        return;
      }

      final data = {'user_id': userId};
      final response = await http.post(
        Uri.parse('http://localhost:8000/user_budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        // Verifica se o corpo contém indicação de "nenhum item encontrado"
        if (body.isEmpty || body.contains('Nenhum item encontrado') || body.contains('nenhum item encontrado')) {
          setState(() {
            userBudgets = [];
            errorMessage = null; // Sem erro, só lista vazia
            isLoading = false;
          });
          return;
        }

        List<dynamic> dataList;
        try {
          dataList = jsonDecode(body) as List<dynamic>;
        } catch (e) {
          setState(() {
            errorMessage = 'Erro ao processar resposta da API.';
            isLoading = false;
          });
          return;
        }

        final List<Map<String, dynamic>> parsed = dataList.map<Map<String, dynamic>>((item) {
          // Aqui assume-se que `item` é um Map<String, dynamic> vindo da API
          final map = item as Map<String, dynamic>;
          // Exemplo de parsing semelhante ao código anterior:
          // Extrai horas
          int totalHours = 0;
          final rawHours = map['hours'];
          if (rawHours != null) {
            if (rawHours is num) {
              totalHours = rawHours.toInt();
            } else {
              totalHours = int.tryParse(rawHours.toString()) ?? 0;
            }
          }
          // Cálculo total de drinks
          double totalDrinksPrice = 0.0;
          final drinksList = <String>[];
          if (map['drinks'] is List) {
            for (var drink in map['drinks']) {
              if (drink is Map<String, dynamic>) {
                final name = drink['name'] ?? '';
                final type = drink['type'] ?? '';
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
                drinksList.add('$name ($type) x$quantity - R\$${precoStr}');
              }
            }
          }
          // Cálculo de labor
          double totalLaborPrice = 0.0;
          double totalBartenderPrice = 0.0;
          double totalGarconPrice = 0.0;
          double bartenderHourlyRate = 0.0;
          double garconHourlyRate = 0.0;

          if (map['labor'] is List) {
            for (var l in map['labor']) {
              if (l is Map<String, dynamic>) {
                final type = l['type'] ?? '';
                final quantityNum = l['quantity'];
                final priceNum = l['price_per_hour'];
                final quantity = (quantityNum is num)
                    ? quantityNum.toInt()
                    : int.tryParse(quantityNum.toString()) ?? 0;
                final pricePerHour = (priceNum is num)
                    ? priceNum.toDouble()
                    : double.tryParse(priceNum.toString()) ?? 0.0;
                if (type == 'Bartender' && bartenderHourlyRate == 0.0) {
                  bartenderHourlyRate = pricePerHour;
                }
                if ((type == 'Garçom' || type.toString().toLowerCase().contains('garçom')) && garconHourlyRate == 0.0) {
                  garconHourlyRate = pricePerHour;
                }
                final custo = quantity * pricePerHour * totalHours;
                totalLaborPrice += custo;
                if (type == 'Bartender') {
                  totalBartenderPrice += custo;
                } else if (type == 'Garçom' || type.toString().toLowerCase().contains('garçom')) {
                  totalGarconPrice += custo;
                }
              }
            }
          }
          // Quantidades de cada tipo
          int totalBartenders = 0;
          int totalGarcons = 0;
          if (map['labor'] is List) {
            for (var l in map['labor']) {
              if (l is Map<String, dynamic>) {
                final type = l['type'] ?? '';
                final quantityNum = l['quantity'];
                final qty = (quantityNum is num)
                    ? quantityNum.toInt()
                    : int.tryParse(quantityNum.toString()) ?? 0;
                if (type == 'Bartender') {
                  totalBartenders += qty;
                } else if (type == 'Garçom') {
                  totalGarcons += qty;
                }
              }
            }
          }
          // Identificador do orçamento: usar campo id se existir, senão name
          final idField = map.containsKey('id') ? map['id'].toString() : map['name'].toString();

          return {
            "id": idField,
            "name": map["name"]?.toString() ?? '',
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

        setState(() {
          userBudgets = parsed;
          isLoading = false;
          errorMessage = null;
        });
      } else if (response.statusCode == 204) {
        // No Content
        setState(() {
          userBudgets = [];
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
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteBudget(String budgetId, String budgetName) async {
    // budgetId pode ser o campo "id" ou usar name se não tiver id único
    try {
      String? userId = context.read<UserData>().userId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
        return;
      }

      final data = {
        'user_id': userId,
        'budget_id': budgetId,
      };

      final response = await http.post(
        Uri.parse('http://localhost:8000/delete_budget/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        setState(() {
          userBudgets.removeWhere((b) => b['id'] == budgetId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Orçamento "$budgetName" excluído com sucesso.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060605),
      appBar: AppBar(
        title: const Text(
          'Meus Orçamentos',
          style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD0A74C)),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontFamily: 'Poppins'),
                  ),
                )
              : userBudgets.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum orçamento encontrado.',
                        style: const TextStyle(
                          color: Color(0xFFD0A74C),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchUserBudgets,
                      color: const Color(0xFFD0A74C),
                      child: ListView.builder(
                        itemCount: userBudgets.length,
                        itemBuilder: (context, index) {
                          final budget = userBudgets[index];
                          final totalDrinks = budget['totalDrinksPrice'] as double;
                          final totalLabor = budget['totalLaborPrice'] as double;
                          final total = budget['totalPrice'] as double;
                          final hours = budget['hours'] as int;
                          final bartenderRate = budget['bartenderHourlyRate'] as double;
                          final garconRate = budget['garconHourlyRate'] as double;
                          final budgetName = budget['name'] as String;
                          final budgetId = budget['id'] as String;

                          return Card(
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFD0A74C), width: 2),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budgetName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Horas trabalhadas: $hours",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Drinks:\n ${budget['drinks'].join('\n ')}",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Preço total das bebidas: R\$${totalDrinks.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Bartenders: ${budget['bartenders']}  -  R\$${bartenderRate.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    "Garçons: ${budget['garcons']}  -  R\$${garconRate.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Preço total dos trabalhadores: R\$${totalLabor.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const Divider(color: Color(0xFFD0A74C)),
                                  Text(
                                    "Preço total do atendimento: R\$${total.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD0A74C),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Confirmar exclusão'),
                                              content: Text('Deseja excluir o orçamento "$budgetName"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    deleteBudget(budgetId, budgetName);
                                                  },
                                                  child: const Text(
                                                    'Excluir',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
