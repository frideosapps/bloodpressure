import 'package:flutter_test/flutter_test.dart';

import 'package:bloodpressure/src/blocs/bloodpressure_bloc.dart';
import 'package:bloodpressure/src/models/bloodpressure_model.dart';

class BloodPressureTest {
  double diastolic;
  double systolic;
  Classification c;
  BloodPressureTest(this.diastolic, this.systolic, this.c);
}

List<BloodPressureTest> tests = [
  BloodPressureTest(65.0, 80.0, Classification.low),
  BloodPressureTest(50.0, 110.0, Classification.isolatedDiastolic),
  BloodPressureTest(70.0, 110.0, Classification.optimal),
  BloodPressureTest(80.0, 120.0, Classification.normal),
  BloodPressureTest(80.0, 137.0, Classification.high),
  BloodPressureTest(80.0, 141.0, Classification.grade1),
  BloodPressureTest(80.0, 161.0, Classification.grade2),
  BloodPressureTest(80.0, 181.0, Classification.grade3),
  BloodPressureTest(80.0, 160.0, Classification.isolatedSystolic),
];

void main() {
  final bloc = BloodPressureBloc();

  test('Classification testing', () {
    bloc.systolic.inStream(tests[0].systolic.toString());
    bloc.diastolic.inStream(tests[0].diastolic.toString());
    bloc.systolicBP = double.tryParse(bloc.systolic.value);
    bloc.diastolicBP = double.tryParse(bloc.diastolic.value);

    bloc.examine();

    expect(bloc.result.history.last.classification, tests[0].c);

    bloc.dispose();  
  });


}
