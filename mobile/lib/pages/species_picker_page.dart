import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/model/species.dart';
import 'package:mobile/pages/picker_page.dart';
import 'package:mobile/species_manager.dart';

class SpeciesPickerPage extends StatefulWidget {
  final void Function(BuildContext, Species) onPicked;

  SpeciesPickerPage({
    this.onPicked,
  }) : assert(onPicked != null);

  @override
  _SpeciesPickerPageState createState() => _SpeciesPickerPageState();
}

class _SpeciesPickerPageState extends State<SpeciesPickerPage> {
  List<Species> _species = [];

  @override
  Widget build(BuildContext context) {
    return SpeciesBuilder(
      onUpdate: (species) {
        _species = species;
      },
      builder: (context) => PickerPage<Species>.single(
        title: Text(Strings.of(context).speciesPickerPageTitle),
        itemBuilder: () => entityListToPickerPageItemList<Species>(_species),
        onFinishedPicking: widget.onPicked,
        itemManager: PickerPageItemSpeciesManager(context),
      ),
    );
  }
}