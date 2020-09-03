import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

/// An object that stores data for a single row in a one-to-many database
/// relationship table.
@immutable
class OneToManyRow {
  @protected
  final String firstColumn;

  @protected
  final String secondColumn;

  @protected
  final String firstValue;

  @protected
  final String secondValue;

  @protected
  OneToManyRow({
    @required this.firstColumn,
    @required this.secondColumn,
    @required this.firstValue,
    @required this.secondValue,
  }) : assert(isNotEmpty(firstColumn)),
       assert(isNotEmpty(secondColumn)),
       assert(firstColumn != secondColumn),
       assert(isNotEmpty(firstValue)),
       assert(isNotEmpty(secondValue));

  @protected
  OneToManyRow.fromMap({
    @required String firstColumn,
    @required String secondColumn,
    @required Map<String, dynamic> map,
  }) : this(
    firstColumn: firstColumn,
    secondColumn: secondColumn,
    firstValue: map[firstColumn],
    secondValue: map[secondColumn],
  );

  Map<String, dynamic> toMap() => {
    firstColumn: firstValue,
    secondColumn: secondValue,
  };
}