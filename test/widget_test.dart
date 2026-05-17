import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alpine_plant_map/main.dart';

void main() {
  testWidgets('AlpinePlantMap が起動する', (WidgetTester tester) async {
    await tester.pumpWidget(const AlpinePlantMap());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}