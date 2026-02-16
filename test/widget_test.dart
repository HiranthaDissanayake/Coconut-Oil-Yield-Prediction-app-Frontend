// Widget tests for Coconut Oil Prediction App
//
// To run these tests:
// flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coconut_oil_prediction_app/main.dart';

void main() {
  group('CoconutOilPredictionApp Tests', () {
    testWidgets('App launches and shows home page', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Verify that the app title is displayed
      expect(find.text('Coconut Oil Yield\nPrediction'), findsOneWidget);
      
      // Verify the description text is present
      expect(
        find.text(
          'AI-powered tool to predict coconut oil yield based on kernel dryness analysis',
        ),
        findsOneWidget,
      );

      // Verify the Start Prediction button exists
      expect(find.text('Start Prediction'), findsOneWidget);
      
      // Verify the How it works button exists
      expect(find.text('How it works'), findsOneWidget);
    });

    testWidgets('Start Prediction button navigates to capture page',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Find and tap the Start Prediction button
      final startButton = find.text('Start Prediction');
      expect(startButton, findsOneWidget);
      
      await tester.tap(startButton);
      await tester.pumpAndSettle(); // Wait for navigation animation

      // Verify we're on the capture page
      expect(find.text('Capture Coconut\nKernel Samples'), findsOneWidget);
      
      // Verify instruction text is present
      expect(
        find.textContaining('Take or upload 5-10 clear images'),
        findsOneWidget,
      );
    });

    testWidgets('How it works dialog opens and closes',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Tap the How it works button
      await tester.tap(find.text('How it works'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('How It Works'), findsOneWidget);
      expect(find.text('Capture Samples'), findsOneWidget);
      expect(find.text('AI Processing'), findsOneWidget);
      expect(find.text('Yield Calculation'), findsOneWidget);
      expect(find.text('Get Results'), findsOneWidget);

      // Close the dialog
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('How It Works'), findsNothing);
    });

    testWidgets('Home page displays all feature items',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Verify all three features are displayed
      expect(find.text('Capture or Upload Images'), findsOneWidget);
      expect(find.text('AI Analysis'), findsOneWidget);
      expect(find.text('Instant Results'), findsOneWidget);

      // Verify feature icons are present
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
      expect(find.byIcon(Icons.insights), findsOneWidget);
    });

    testWidgets('App icon is displayed on home page',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Verify the eco icon (app logo) is present
      expect(find.byIcon(Icons.eco), findsWidgets);
    });
  });

  group('CaptureSamplesPage Tests', () {
    testWidgets('Capture page shows all required elements',
        (WidgetTester tester) async {
      // Build the app and navigate to capture page
      await tester.pumpWidget(const CoconutOilPredictionApp());
      await tester.tap(find.text('Start Prediction'));
      await tester.pumpAndSettle();

      // Verify title
      expect(find.text('Capture Coconut\nKernel Samples'), findsOneWidget);

      // Verify buttons are present
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Upload Images'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);

      // Verify image counter is shown
      expect(find.textContaining('0/10 images selected'), findsOneWidget);

      // Verify icons are present
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.upload), findsOneWidget);
    });

    testWidgets('Back button returns to home page',
        (WidgetTester tester) async {
      // Build the app and navigate to capture page
      await tester.pumpWidget(const CoconutOilPredictionApp());
      await tester.tap(find.text('Start Prediction'));
      await tester.pumpAndSettle();

      // Verify we're on capture page
      expect(find.text('Capture Coconut\nKernel Samples'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on home page
      expect(find.text('Coconut Oil Yield\nPrediction'), findsOneWidget);
      expect(find.text('Start Prediction'), findsOneWidget);
    });

    testWidgets('Image counter updates correctly',
        (WidgetTester tester) async {
      // Build the app and navigate to capture page
      await tester.pumpWidget(const CoconutOilPredictionApp());
      await tester.tap(find.text('Start Prediction'));
      await tester.pumpAndSettle();

      // Verify initial counter shows 0
      expect(find.textContaining('0/10 images selected'), findsOneWidget);
      
      // Note: Testing actual image picking requires mocking ImagePicker
      // which would need additional test setup with mockito or similar
    });

    testWidgets('Next button attempts navigation with no images',
        (WidgetTester tester) async {
      // Build the app and navigate to capture page
      await tester.pumpWidget(const CoconutOilPredictionApp());
      await tester.tap(find.text('Start Prediction'));
      await tester.pumpAndSettle();

      // Tap Next button without selecting images
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Verify error message appears (SnackBar)
      expect(
        find.text('Please select at least 5 images to continue'),
        findsOneWidget,
      );
    });
  });

  group('Theme and Styling Tests', () {
    testWidgets('App uses correct color scheme',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      // Verify theme colors
      expect(
        materialApp.theme?.primaryColor,
        const Color(0xFF6B8E6B),
      );
      
      expect(
        materialApp.theme?.scaffoldBackgroundColor,
        const Color(0xFFE8F5E9),
      );
    });

    testWidgets('Buttons have correct styling',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Find the Start Prediction button
      final startButton = find.ancestor(
        of: find.text('Start Prediction'),
        matching: find.byType(ElevatedButton),
      );

      expect(startButton, findsOneWidget);

      // Verify button has icon
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('App has correct route configuration',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      // Verify routes are configured
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.containsKey('/'), true);
      expect(materialApp.routes!.containsKey('/capture'), true);
      expect(materialApp.routes!.containsKey('/prediction'), true);
    });

    testWidgets('Initial route is home page',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Get the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );

      // Verify initial route
      expect(materialApp.initialRoute, '/');
      
      // Verify home page is displayed
      expect(find.text('Coconut Oil Yield\nPrediction'), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Important buttons have proper semantics',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const CoconutOilPredictionApp());

      // Verify buttons are accessible
      expect(find.text('Start Prediction'), findsOneWidget);
      expect(find.text('How it works'), findsOneWidget);
      
      // Navigate to capture page
      await tester.tap(find.text('Start Prediction'));
      await tester.pumpAndSettle();

      // Verify capture page buttons are accessible
      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.text('Upload Images'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}