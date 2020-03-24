import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/fishing_spot.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/widget.dart';

class FishingSpotPickerPage extends StatefulWidget {
  final void Function(BuildContext, FishingSpot) onPicked;

  FishingSpotPickerPage({
    @required this.onPicked,
  }) : assert(onPicked != null);

  @override
  _FishingSpotPickerPageState createState() => _FishingSpotPickerPageState();
}

class _FishingSpotPickerPageState extends State<FishingSpotPickerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.of(context).fishingSpotPickerPageTitle),
        centerTitle: false,
        actions: [
          ActionButton(
            text: Strings.of(context).next,
            onPressed: () => widget.onPicked(context, null),
          ),
        ],
      ),
      body: Empty(),
    );
  }
}