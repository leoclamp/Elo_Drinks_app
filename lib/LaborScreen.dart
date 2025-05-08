import 'package:flutter/material.dart';

class LaborScreen extends StatefulWidget {
  @override
  _LaborScreenState createState() => _LaborScreenState();
}

class _LaborScreenState extends State<LaborScreen> {
  // Preço por hora
  final double pricePerHour = 10.0;

  // Variáveis para controlar o número de bartenders, garçons e horas
  int bartenderCount = 0;
  int waiterCount = 0;
  int hours = 0;

  // Calcular o preço total
  double get totalPrice => (bartenderCount + waiterCount) * hours * pricePerHour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF060605),
      appBar: AppBar(
        title: Text(
          "Escolher Mão de Obra",
          style: TextStyle(
            color: Color(0xFFD0A74C),
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color(0xFFD0A74C)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Bartender",
                  style: TextStyle(
                    color: Color(0xFFD0A74C),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          if (bartenderCount > 0) bartenderCount--;
                        });
                      },
                    ),
                    Text(
                      "$bartenderCount",
                      style: TextStyle(
                        color: Color(0xFFD0A74C),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          bartenderCount++;
                        });
                      },
                    ),
                    Text(
                      " - Preço por hora: R\$${pricePerHour.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Color(0xFFD0A74C),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Garçom",
                  style: TextStyle(
                    color: Color(0xFFD0A74C),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          if (waiterCount > 0) waiterCount--;
                        });
                      },
                    ),
                    Text(
                      "$waiterCount",
                      style: TextStyle(
                        color: Color(0xFFD0A74C),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          waiterCount++;
                        });
                      },
                    ),
                    Text(
                      " - Preço por hora: R\$${pricePerHour.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Color(0xFFD0A74C),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Hours selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Horas:",
                  style: TextStyle(
                    color: Color(0xFFD0A74C),
                    fontSize: 18,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          if (hours > 0) hours--;
                        });
                      },
                    ),
                    Text(
                      "$hours",
                      style: TextStyle(
                        color: Color(0xFFD0A74C),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Color(0xFFD0A74C)),
                      onPressed: () {
                        setState(() {
                          hours++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Text(
              "Preço Total: R\$${totalPrice.toStringAsFixed(2)}",
              style: TextStyle(
                color: Color(0xFFD0A74C),
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 20),

            // Confirm button
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
                if ((bartenderCount > 0 || waiterCount > 0) && hours > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Mão de obra confirmada: $bartenderCount Bartenders e $waiterCount Garçons por $hours horas. Preço Total: R\$${totalPrice.toStringAsFixed(2)}",
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Selecione ao menos um bartender, garçom e as horas!")),
                  );
                }
              },
              child: Text(
                "Confirmar Seleção",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
