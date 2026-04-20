import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:student_task_manager/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const StudentTaskManagerApp(themeMode: ThemeMode.light),
    );

    expect(find.byType(StudentTaskManagerApp), findsOneWidget);
  });
}