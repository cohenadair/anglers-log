import 'package:flutter/material.dart';

const int snackBarDurationDefault = 5;

void showErrorSnackBar(BuildContext context, String errorMessage) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(errorMessage),
    duration: Duration(seconds: snackBarDurationDefault),
    backgroundColor: Colors.red,
  ));
}

void showPermanentSnackBar(BuildContext context, String message) {
  Scaffold.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(days: 365),
  ));
}