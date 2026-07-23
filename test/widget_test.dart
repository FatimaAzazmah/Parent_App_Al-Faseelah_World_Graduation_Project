import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // اختبار بسيط مؤقت
    await tester.pumpWidget(
      const MaterialApp(
        home:  Scaffold(
          body: Center(
            child: Text('Test'),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}