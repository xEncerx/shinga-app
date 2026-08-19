import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('SaFormTextField validates and saves its unmodified value', (tester) async {
    final formKey = GlobalKey<FormState>();
    String? savedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SaFormTextField(
              validator: (value) => value == null || value.isEmpty ? 'required' : null,
              onSaved: (value) => savedValue = value,
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '  Passwor1  ');
    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();

    expect(savedValue, '  Passwor1  ');
  });

  testWidgets('SaFormTextField exposes validation errors with a custom decoration', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SaFormTextField(
              decoration: const InputDecoration(labelText: 'Field'),
              validator: (_) => 'invalid',
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('invalid'), findsOneWidget);
  });

  testWidgets('SaFormTextField forwards its disabled state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Form(
            child: SaFormTextField(enabled: false),
          ),
        ),
      ),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('SaFormPinField shows an error state without rendering error text', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: SaFormPinField(validator: (_) => 'invalid code'),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(tester.widget<SaPinField>(find.byType(SaPinField)).showError, isTrue);
    expect(find.text('invalid code'), findsNothing);
  });
}
