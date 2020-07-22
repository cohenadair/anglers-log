import 'package:flutter/material.dart';
import 'package:mobile/model/custom_report.dart';
import 'package:mobile/widgets/widget.dart';

class SaveReportPage extends StatelessWidget {
  final CustomReport oldReport;

  SaveReportPage() : oldReport = null;
  SaveReportPage.edit(this.oldReport);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO"),
      ),
      body: Empty(),
    );
  }
}