import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';

class ImportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: CloseButton(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: Empty(),
    );
  }
}