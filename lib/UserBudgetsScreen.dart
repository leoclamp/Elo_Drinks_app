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

    // Se parâmetros de teste são passados, usa eles ao invés de buscar API
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

      final data = {
        'user_id': userId
      };
      
      final response = await http.post(
        Uri.parse('http://localhost:8000/user_budgets/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('UserBudetScreen::POST ==> ${response.statusCode}');
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
      
        setState(() {
          userBudgets = data.map<Map<String, dynamic>>((item) {
            return {
              "name": item["name"],
      
              // Lista de drinks no formato: "Nome (Tipo) xQuantidade"
              "drinks": (item['drinks'] as List)
                  .map<String>((drink) =>
                      '${drink["name"]} (${drink["type"]}) x${drink["quantity"]}x${drink["price_per_liter"]}R\$')
                  .toList(),
      
              // Soma total de bartenders na lista labor
              "bartenders": (item['labor'] as List)
                  .where((l) => l['type'] == 'Bartender')
                  .fold<int>(0, (sum, l) => sum + (l['quantity'] as int)),
      
              // Soma total de garçons na lista labor
              "garcons": (item['labor'] as List)
                  .where((l) => l['type'] == 'Garçom')
                  .fold<int>(0, (sum, l) => sum + (l['quantity'] as int)),
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
        print(e);
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
      body:
          isLoading
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
                  return Card(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                            "Drinks:\n ${budget['drinks'].join('\n ')}",
                            style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            "Bartenders: ${budget['bartenders']}",
                            style: TextStyle(
                              color: Color(0xFFD0A74C),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            "Garçons: ${budget['garcons']}",
                            style: TextStyle(
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
