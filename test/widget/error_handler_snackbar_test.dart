import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tuncforwork/service/error_handler.dart';

void main() {
  late ErrorHandler errorHandler;

  setUp(() {
    Get.testMode = true;
    errorHandler = ErrorHandler();
  });

  tearDown(() {
    Get.reset();
  });

  // Widget test helper
  Widget createTestWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ErrorHandler - Snackbar UI Tests', () {
    testWidgets('showError displays error snackbar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showError('Test error message');
                },
                child: const Text('Show Error'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Error'));
      await tester.pump(); // Start animation
      await tester
          .pump(const Duration(milliseconds: 500)); // Complete animation

      // Assert
      expect(find.text('Hata'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('showSuccess displays success snackbar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showSuccess('Operation successful');
                },
                child: const Text('Show Success'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('showWarning displays warning snackbar',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showWarning('Warning message');
                },
                child: const Text('Show Warning'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Warning'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Warning message'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('showInfo displays info snackbar', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showInfo('Info message');
                },
                child: const Text('Show Info'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Info'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('showLoading displays loading dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showLoading(message: 'Loading data...');
                },
                child: const Text('Show Loading'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('hideLoading closes loading dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      errorHandler.showLoading(message: 'Loading...');
                    },
                    child: const Text('Show Loading'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      errorHandler.hideLoading();
                    },
                    child: const Text('Hide Loading'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      // Act - Show loading
      await tester.tap(find.text('Show Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Loading is visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Act - Hide loading
      await tester.tap(find.text('Hide Loading'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Loading is hidden
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('ErrorHandler - Snackbar Customization', () {
    testWidgets('error snackbar has red background',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showError('Error');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red.shade600);
    });

    testWidgets('success snackbar has green background',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  errorHandler.showSuccess('Success');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.green.shade600);
    });
  });
}
