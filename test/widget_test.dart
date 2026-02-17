// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_google/features/webview/domain/repositories/connectivity_repository.dart';
import 'package:project_google/main.dart';

class MockConnectivityRepository implements ConnectivityRepository {
  @override
  Future<bool> checkConnection() async => true;
  @override
  Stream<bool> get connectionStatus => Stream.fromIterable([true]);
  @override
  Future<void> initialize() async {}
  @override
  void dispose() {}
}

void main() {
  testWidgets('App builds correctly', (WidgetTester tester) async {
    final mockRepository = MockConnectivityRepository();
    await tester.pumpWidget(MyApp(connectivityRepository: mockRepository));

    // Verify the app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
