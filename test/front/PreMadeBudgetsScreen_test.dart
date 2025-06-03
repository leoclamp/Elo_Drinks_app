import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/PreMadeBudgetsScreen.dart';

void main() {
  testWidgets('Mostra loading quando isLoading é true', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreMadeBudgetsScreen(
          testIsLoading: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Mostra mensagem de erro', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreMadeBudgetsScreen(
          testIsLoading: false,
          testErrorMessage: 'Erro de teste',
        ),
      ),
    );

    expect(find.text('Erro de teste'), findsOneWidget);
  });

  testWidgets('Mostra lista de orçamentos', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreMadeBudgetsScreen(
          testIsLoading: false,
          testBudgets: [
            {
              'name': 'Orçamento Teste',
              'drinks': ['Drink1', 'Drink2'],
              'price': 123.45,
            },
          ],
        ),
      ),
    );

    expect(find.text('Orçamento Teste'), findsOneWidget);
    expect(find.textContaining('Drink1'), findsOneWidget);
    expect(find.textContaining('R\$123.45'), findsOneWidget);
  });

  testWidgets('Exibe SnackBar ao clicar em orçamento', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PreMadeBudgetsScreen(
          testIsLoading: false,
          testBudgets: [
            {
              'name': 'Orçamento Teste',
              'drinks': ['Drink1', 'Drink2'],
              'price': 123.45,
            },
          ],
        ),
      ),
    );

    await tester.tap(find.text('Orçamento Teste'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining("Orçamento 'Orçamento Teste' selecionado!"), findsOneWidget);
  });
}
