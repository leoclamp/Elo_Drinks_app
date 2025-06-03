import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PreMadeBudgetsScreen extends StatefulWidget {
  final bool? testIsLoading;
  final String? testErrorMessage;
  final List<Map<String, dynamic>>? testBudgets;

  const PreMadeBudgetsScreen({
    Key? key,
    this.testIsLoading,
    this.testErrorMessage,
    this.testBudgets,
  }) : super(key: key);

  @override
  _PreMadeBudgetsScreenState createState() => _PreMadeBudgetsScreenState();
}

class _PreMadeBudgetsScreenState extends State<PreMadeBudgetsScreen> {
  List<Map<String, dynamic>> preMadeBudgets = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();

    if (widget.testIsLoading != null) {
      // Para testes, usa os valores passados
      isLoading = widget.testIsLoading!;
      preMadeBudgets = widget.testBudgets ?? [];
      errorMessage = widget.testErrorMessage ?? '';
    } else {
      // Em execução normal, busca os dados
      fetchPreMadeBudgets();
    }
  }

  Future<void> fetchPreMadeBudgets() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/pre_made_budgets/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          preMadeBudgets =
              data.map<Map<String, dynamic>>((item) {
                return {
                  "name": item["name"],
                  "drinks": (item["drinks"] as String).split(','),
                  "price": item["price"].toDouble(),
                };
              }).toList();
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar orçamentos (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orçamentos Pré-montados",
          style: TextStyle(color: Color(0xFFD0A74C), fontFamily: 'Poppins'),
        ),
        backgroundColor: Color(0xFF060605),
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      backgroundColor: Color(0xFF060605),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFFD0A74C)),
              )
              : errorMessage.isNotEmpty
              ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontFamily: 'Poppins',
                  ),
                ),
              )
              : ListView.builder(
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
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        ),
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
                            content: Text(
                              "Orçamento '${budget["name"]}' selecionado!",
                            ),
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
