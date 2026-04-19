import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';

@immutable
class TimeSeriesPoint {
  final DateTime at;
  final Decimal value;

  const TimeSeriesPoint({required this.at, required this.value});
}
