import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:frideos/frideos_dart.dart';

import 'bloc_provider.dart';
import '../models/bloodpressure_model.dart';

class BloodPressureBloc extends BlocBase {
  final systolic = StreamedTransformed<String, double>();
  final diastolic = StreamedTransformed<String, double>();
  final result = HistoryObject<BloodPressure>();

  double systolicBP; // systolic value from the transformed stream
  double diastolicBP; // diastolic value from the transformed stream

  BloodPressureBloc() {
    print('------- BlocPressure bloc: INIT --------');

    systolic.setTransformer(validateSystolic);
    diastolic.setTransformer(validateDiastolic);

    systolic.outTransformed.listen((value) {
      if (diastolic.value != null) {
        if (value <= double.tryParse(diastolic.value)) {
          systolic.stream.addError("Systolic must be greater than systolic");
        }
      }
    }).onData((value) => systolicBP = value);

    diastolic.outTransformed.listen((value) {
      if (systolic.value != null) {
        if (value >= double.tryParse(systolic.value)) {
          diastolic.stream.addError("Diastolic must be greater than systolic");
        }
      }
    }).onData((value) => diastolicBP = value);
  }

  final validateSystolic =
      StreamTransformer<String, double>.fromHandlers(handleData: (bp, sink) {
    var p = double.tryParse(bp); // it returns null if invalid input
    if (p != null && p < 300.0) {
      if (p > 0) {
        sink.add(p);
      } else {
        sink.addError('Systolic must be greater than zero.');
      }
    } else {
      sink.addError('Please insert a valid systolic pressure.');
    }
  });

  final validateDiastolic =
      StreamTransformer<String, double>.fromHandlers(handleData: (bp, sink) {
    var p = double.tryParse(bp); // it returns null if invalid input
    if (p != null && p < 200.0) {
      if (p > 0) {
        sink.add(p);
      } else {
        sink.addError('Diastolic must be greater than zero.');
      }
    } else {
      sink.addError('Please insert a valid diastolic pressure.');
    }
  });

  Stream<bool> get isComplete => Observable.combineLatest2(
      diastolic.outTransformed, systolic.outTransformed, (d, s) => true);

  examine() {
    //
    // Calculate the MAP (mean arterial pressure)
    //
    var map = (systolicBP / 3) + (diastolicBP / 3) * 2;
    //
    // Calculate the pulse pressure
    //
    var pulse = systolicBP - diastolicBP;

    Classification classification = Classification.normal;

    //
    // To classify the user's arterial blood pressure
    // according to its systolic and diastolic pressure
    //
    if (systolicBP < 90.0 || diastolicBP < 60.0) {
      if (systolicBP >= 100.0)
        classification = Classification.isolatedDiastolic;
      else
        classification = Classification.low;
    } else {
      if (diastolicBP < 90.0 && systolicBP >= 140.0)
        classification = Classification.isolatedSystolic;
      else if (systolicBP >= 180.0 || diastolicBP >= 110.0)
        classification = Classification.grade3;
      else if (systolicBP >= 160.0 || diastolicBP >= 100.0)
        classification = Classification.grade2;
      else if (systolicBP >= 140.0 || diastolicBP >= 90.0)
        classification = Classification.grade1;
      else if (systolicBP >= 130.0 || diastolicBP >= 85.0)
        classification = Classification.high;
      else if (systolicBP >= 120.0 || diastolicBP >= 80.0)
        classification = Classification.normal;
      else if (systolicBP >= 90.0 || diastolicBP >= 60.0)
        classification = Classification.optimal;
    }

    var bloodPressure =
        new BloodPressure(diastolicBP, systolicBP, map, pulse, classification);

    print('----------RESULT-----------');
    print(bloodPressure.toString());

    //
    // send the result to stream
    //
    result.value = bloodPressure;

    //
    // add the result to the history
    //
    result.saveValue();
  }

  dispose() {
    print('------- BlocPressure bloc: DISPOSE --------');

    systolic.dispose();
    diastolic.dispose();
    result.dispose();
  }
}
