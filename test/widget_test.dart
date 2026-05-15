import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amil_track/main.dart';

void main() {
  testWidgets('app boots with bootstrap screen', (WidgetTester tester) async {
    await tester.pumpWidget(const AmilTrackApp());

    expect(find.text('Amil Track siap dimuat'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
