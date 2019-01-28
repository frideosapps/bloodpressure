import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bloodpressure/src/bloodpressure_page.dart';
import 'package:bloodpressure/src/blocs/bloc_provider.dart';
import 'package:bloodpressure/src/blocs/bloodpressure_bloc.dart';

main() {
  final bloc = BloodPressureBloc();

  testWidgets('Arterial blood pressure classification',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          bloc: bloc,
          child: BloodPressurePage(),
        ),
      ),
    );

    final systolic = find.byKey(Key('systolic'));
    await tester.enterText(systolic, '125');

    final diastolic = find.byKey(Key('diastolic'));
    await tester.enterText(diastolic, '100');

    //Now the button is enabled
    await tester.pump();

    Finder examine = find.byKey(new Key('examine'));
    await tester.tap(examine);

    //Showing the result
    await tester.pump();

    expect(find.text('125 mmHg'), findsOneWidget);
    expect(find.text('100 mmHg'), findsOneWidget);
    expect(find.text('Grade 2 hypertension'), findsOneWidget);

    //TEST 2
    await tester.enterText(systolic, '89');
    await tester.enterText(diastolic, '60');
    await tester.pump();
    await tester.tap(examine);
    await tester.pump();
    expect(find.text('89 mmHg'), findsOneWidget);
    expect(find.text('60 mmHg'), findsOneWidget);
    expect(find.text('Hypotension'), findsOneWidget);

    bloc.dispose();
  });
}
