import 'package:deliveristo_challenge_johassan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the generate button, verify image',
            (tester) async {
      toTest=true;
              await tester.pumpWidget(const DeliveristoChallenge());
          expect(find.text('Generate'), findsOneWidget);
          final Finder fab = find.byKey(const Key('generateBtnKey'));
          await tester.tap(fab);
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('imageKey')), findsOneWidget);
        });
  });
}