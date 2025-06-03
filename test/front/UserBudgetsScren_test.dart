import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/UserBudgetsScreen.dart';

void main() {
  testWidgets('Mostra loading quando isLoading é true', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserBudgetsScreen(
          testIsLoading: true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Mostra mensagem de erro', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserBudgetsScreen(
          testIsLoading: false,
          testErrorMessage: 'Erro de teste',
        ),
      ),
    );

    expect(find.text('Erro de teste'), findsOneWidget);
  });

  testWidgets('Mostra mensagem quando lista está vazia', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UserBudgetsScreen(
          testIsLoading: false,
          testBudgets: [],
        ),
      ),
    );

    expect(find.text('Nenhum orçamento encontrado.'), findsOneWidget);
  });

  testWidgets('Mostra lista de orçamentos', (WidgetTester tester) async {
    final sampleBudgets = [
      {
        'name': 'Orçamento Teste',
        'drinks': ['Drink1', 'Drink2'],
        'bartenders': 2,
        'garcons': 3,
        'horas': 5,
        'preco': 150.00,
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: UserBudgetsScreen(
          testIsLoading: false,
          testBudgets: sampleBudgets,
        ),
      ),
    );

    expect(find.text('Orçamento Teste'), findsOneWidget);
    expect(find.textContaining('Drink1'), findsOneWidget);
    expect(find.textContaining('Bartenders: 2'), findsOneWidget);
    expect(find.textContaining('Garçons: 3'), findsOneWidget);
    expect(find.textContaining('Horas: 5'), findsOneWidget);
    expect(find.textContaining('R\$150.00'), findsOneWidget);
  });
}
