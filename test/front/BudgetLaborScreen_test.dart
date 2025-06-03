import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/BudgetLaborScreen.dart'; 

void main() {
  testWidgets('Renderiza a tela e interage com campos básicos', (WidgetTester tester) async {
    // Monta a tela
    await tester.pumpWidget(MaterialApp(home: BudgetLaborScreen()));

    // Verifica se título e campo de nome estão presentes
    expect(find.text('Orçamento e Mão de Obra'), findsOneWidget);
    expect(find.text('Nome do Orçamento'), findsOneWidget);

    // Preenche nome do orçamento
    await tester.enterText(find.byType(TextField), 'Festa de Aniversário');
    expect(find.text('Festa de Aniversário'), findsOneWidget);

    // Aumenta número de bartenders
    final addBartenderButton = find.widgetWithIcon(IconButton, Icons.add).at(0);
    await tester.tap(addBartenderButton);
    await tester.pump();

    expect(find.text('1'), findsOneWidget);

    // Aumenta número de garçons
    final addWaiterButton = find.widgetWithIcon(IconButton, Icons.add).at(1);
    await tester.tap(addWaiterButton);
    await tester.pump();

    expect(find.text('1'), findsNWidgets(2)); // bartender e garçom

    // Aumenta número de horas
    final addHoursButton = find.widgetWithIcon(IconButton, Icons.add).at(2);
    await tester.tap(addHoursButton);
    await tester.pump();

    expect(find.text('1'), findsNWidgets(3)); // bartender, garçom e hora

    // Tenta salvar sem selecionar drinks
    final saveButton = find.text('Salvar Orçamento');
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.textContaining('Preencha todos os campos'), findsOneWidget);
  });
}
