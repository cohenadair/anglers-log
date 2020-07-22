import 'package:flutter/material.dart';

/// An abstract class to be implemented by all stats reports, both pre and user
/// defined.
abstract class Report {
  String get id;
  String title(BuildContext context);
}