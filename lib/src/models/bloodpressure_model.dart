import 'package:flutter/material.dart';

enum Classification {
  low,
  isolatedDiastolic,
  optimal,
  normal,
  high,
  grade1,
  grade2,
  grade3,
  isolatedSystolic
}

class BloodPressure {
  double systolic;
  double diastolic;
  double map; //mean arterial pressure
  double pulse; //pulse pressure
  Classification classification;

  BloodPressure(
      this.diastolic, this.systolic, this.map, this.pulse, this.classification);

  @override
  String toString() {
    return "$classification \nSystolic: $systolic mmHg \nDiastolic: $diastolic mmHg \nMAP: $map mmHg \nPulse: $pulse mmHg";
  }
}

final resultsMap = <Classification, Map<String, dynamic>>{
  Classification.low: {'text': 'Hypotension', 'color': Colors.red},
  Classification.isolatedDiastolic: {
    'text': 'Isolated diastolic hypotension',
    'color': Colors.red
  },
  Classification.optimal: {'text': 'Optimal', 'color': Colors.green},
  Classification.normal: {'text': 'Normal', 'color': Colors.green},
  Classification.high: {'text': 'High normal', 'color': Colors.orange},
  Classification.grade1: {
    'text': 'Grade 1 hypertension',
    'color': Colors.deepOrange
  },
  Classification.grade2: {'text': 'Grade 2 hypertension', 'color': Colors.red},
  Classification.grade3: {
    'text': 'Grade 3 hypertension',
    'color': Colors.red[700]
  },
  Classification.isolatedSystolic: {
    'text': 'Isolated systolic hypertension',
    'color': Colors.red
  },
};
