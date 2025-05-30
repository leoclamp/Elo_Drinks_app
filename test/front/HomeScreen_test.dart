import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/HomeScreen.dart';
import 'package:app_bebidas/PreMadeBudgetsScreen.dart';
import 'package:app_bebidas/LoginScreen.dart';
import 'package:app_bebidas/BudgetLaborScreen.dart';
import 'package:app_bebidas/UserBudgetsScreen.dart';

void main() {
  testWidgets('Testa botões da HomeScreen', (WidgetTester tester) async {
    // Renderiza a tela HomeScreen dentro de um MaterialApp, simulando o ambiente do app
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));

    // Verifica se o texto "Montar Orçamento + Mão de Obra" está visível na tela
    expect(find.text('Montar Orçamento + Mão de Obra'), findsOneWidget);

    // Verifica se o texto "Ver Orçamentos Pré-montados" está visível
    expect(find.text('Ver Orçamentos Pré-montados'), findsOneWidget);

    // Verifica se o texto "Sair da conta" está visível
    expect(find.text('Sair da conta'), findsOneWidget);
  });

  testWidgets(
    'Navega para BudgetLaborScreen ao clicar em "Montar Orçamento + Mão de Obra"',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));
      expect(find.text('Montar Orçamento + Mão de Obra'), findsOneWidget);
      await tester.tap(find.text('Montar Orçamento + Mão de Obra'));
      await tester.pumpAndSettle();
      expect(find.byType(BudgetLaborScreen), findsOneWidget);
    },
  );
  testWidgets(
    'Navega para PreMadeBudgetsScreen ao clicar em "Ver Orçamentos Pré-montados"',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));
      expect(find.text('Ver Orçamentos Pré-montados'), findsOneWidget);
      await tester.tap(find.text('Ver Orçamentos Pré-montados'));
      await tester.pumpAndSettle();
      expect(find.byType(PreMadeBudgetsScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Navega para UserBudgetsScreen ao clicar em "Ver Meus Orçamentos"',
    (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));
      expect(find.text('Ver Meus Orçamentos'), findsOneWidget);
      await tester.tap(find.text('Ver Meus Orçamentos'));
      await tester.pumpAndSettle();
      expect(find.byType(UserBudgetsScreen), findsOneWidget);
    },
  );

  testWidgets('Navega para LoginScreen ao clicar em "Sair da conta"', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    expect(find.text('Sair da conta'), findsOneWidget);
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
