import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_study/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartStudyApp());

    // Verifies that the app structural foundation exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}