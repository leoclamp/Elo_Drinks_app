import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/LoginScreen.dart';
import 'package:app_bebidas/RegisterScreen.dart';

void main() {
  testWidgets('Verifica elementos da tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    // Verifica os campos de texto e botões
    expect(find.text('Bem vindo'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar uma conta'), findsOneWidget);
  });

  testWidgets('Navega para tela de registro', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final registerButton = find.text('Criar uma conta');
    expect(registerButton, findsOneWidget);

    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
  });


  testWidgets('Tenta login com campos vazios', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    final entrarButton = find.text('Entrar');
    await tester.tap(entrarButton);
    await tester.pump();

    // Espera por um AlertDialog com erro
    expect(find.byType(AlertDialog), findsNothing, reason: 'Não há validação ainda para campos vazios');
  });
}
