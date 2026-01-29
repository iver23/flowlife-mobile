// FlowLife Mobile - Widget Tests
//
// These tests verify the core UI components of the FlowLife application.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flowlife_mobile/presentation/widgets/ui_components.dart';

void main() {
  group('FlowCard Widget Tests', () {
    testWidgets('FlowCard renders with child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FlowCard(
                child: Text('Test Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('FlowCard responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FlowCard(
                onTap: () => tapped = true,
                child: const Text('Tappable Card'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable Card'));
      expect(tapped, isTrue);
    });
  });

  group('FlowButton Widget Tests', () {
    testWidgets('FlowButton renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FlowButton(
                label: 'Click Me',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });
  });

  group('FlowProgressBar Widget Tests', () {
    testWidgets('FlowProgressBar renders with progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FlowProgressBar(progress: 0.5),
            ),
          ),
        ),
      );

      // Verify the widget tree contains the progress bar
      expect(find.byType(FlowProgressBar), findsOneWidget);
    });
  });

  group('FlowBadge Widget Tests', () {
    testWidgets('FlowBadge renders with label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FlowBadge(label: 'Active'),
            ),
          ),
        ),
      );

      expect(find.text('ACTIVE'), findsOneWidget);
    });
  });
}
