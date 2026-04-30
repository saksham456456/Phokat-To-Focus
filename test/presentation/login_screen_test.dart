import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:phokat_to_focus/features/auth/presentation/login_screen.dart';
import 'package:phokat_to_focus/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LoginScreen form validation catches empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginScreen(),
        ),
      ),
    );

    // Tap the submit button without entering anything
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Expect validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('LoginScreen form validation catches invalid email', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: const LoginScreen(),
        ),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'bademail');
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Expect email validation error
    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });
}
