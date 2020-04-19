import 'package:flutter/material.dart';
import 'package:mobile/entity_manager.dart';
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
  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder<Species>(
      manager: _speciesManager,
      builder: (context) => PickerPage<Species>.single(
        title: Text(Strings.of(context).speciesPickerPageTitle),
        itemBuilder: () => entityListToPickerPageItemList<Species>(
            _speciesManager.entityList),
        onFinishedPicking: widget.onPicked,
        itemManager: PickerPageItemSpeciesManager(context),
      ),
    );
  }
}