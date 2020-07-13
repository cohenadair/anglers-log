import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/widgets/stats_overview.dart';
import 'package:mobile/widgets/widget.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildReportDropdown(),
      ),
      body: StatsOverview(),
    );
  }

  Widget _buildReportDropdown() {
    return DropdownButton(
      underline: Empty(),
      icon: DropdownIcon(),
      value: "Overview",
      items: <DropdownMenuItem>[
        AppBarDropdownItem<String>(
          context: context,
          text: Strings.of(context).statsPageNewReport,
          value: "New Report",
        ),
        AppBarDropdownItem<String>(
          context: context,
          text: Strings.of(context).statsPageReportOverview,
          value: "Overview",
        ),
      ],
      onChanged: (value) {
        print(value);
      },
    );
  }
}

