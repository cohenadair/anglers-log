import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/widgets/text.dart';

class NoResults extends StatelessWidget {
  final String text;

  NoResults(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: insetsDefault,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LabelText(text: text),
            ],
          ),
        ],
      ),
    );
  }
}