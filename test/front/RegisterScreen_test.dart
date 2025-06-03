import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_bebidas/RegisterScreen.dart';

void main() {
  testWidgets('Mostra campos e botão na tela de cadastro', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RegisterScreen()),
    );

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.widgetWithText(TextField, 'Nome'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Senha'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
  });

  testWidgets('Chama função onRegister ao clicar no botão', (WidgetTester tester) async {
    var called = false;

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(
          onRegister: () async {
            called = true;
          },
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump();

    expect(called, isTrue);
  });

  testWidgets('Mostra SnackBar com mensagem de sucesso', (WidgetTester tester) async {
    Future<void> fakeRegister() async {
      final context = tester.element(find.byType(RegisterScreen));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: RegisterScreen(onRegister: fakeRegister),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Cadastro realizado com sucesso!'), findsOneWidget);
  });
}
