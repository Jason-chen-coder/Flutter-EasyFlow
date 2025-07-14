// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_easy_flow/main.dart';
import 'package:flutter_easy_flow/services/theme_service.dart';

void main() {
  testWidgets('Theme switching test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: const MyApp(),
      ),
    );

    // Verify that the app starts with light theme
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.light);

    // Find and tap the theme toggle button
    final themeToggleButton = find.byIcon(Icons.dark_mode);
    expect(themeToggleButton, findsOneWidget);
    
    await tester.tap(themeToggleButton);
    await tester.pump();

    // Verify the icon changed to light mode icon (indicating dark theme is active)
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
  });

  testWidgets('App title and navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: const MyApp(),
      ),
    );

    // Verify that the app title shows correctly
    expect(find.text('Flutter-EasyFlow'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
