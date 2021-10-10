import 'package:flutter/material.dart';

const int snackBarDurationDefault = 5;

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(errorMessage),
    duration: const Duration(seconds: snackBarDurationDefault),
    backgroundColor: Colors.red,
  ));
}

void showPermanentSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: const Duration(days: 365),
  ));
}
