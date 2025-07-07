import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/pages/manageable_list_page.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/utils/collection_utils.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/utils/widget_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/list_item.dart';
import 'package:quiver/strings.dart';

import '../model/gen/anglers_log.pb.dart';
import '../utils/protobuf_utils.dart';
import '../utils/snackbar_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/input_controller.dart';
import '../widgets/widget.dart';
import 'form_page.dart';
import 'species_list_page.dart';
import 'trip_list_page.dart';

class SpeciesCounterPage extends StatefulWidget {
  @override
  State<SpeciesCounterPage> createState() => _SpeciesCounterPageState();
}

class _SpeciesCounterPageState extends State<SpeciesCounterPage> {
  static const _textFieldSize = 45.0;

  final _speciesController = SetInputController<Id>();

  var _counts = <Id, int>{};

  SpeciesManager get _speciesManager => SpeciesManager.of(context);

  TripManager get _tripManager => TripManager.of(context);

  @override
  void initState() {
    super.initState();
    _counts = UserPreferenceManager.get.speciesCounter;
    _speciesController.value = _counts.keys.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        title: Text(Strings.of(context).speciesCounterPageTitle),
        actions: [
          ActionButton(
            text: Strings.of(context).speciesCounterPageReset,
            condensed: true,
            onPressed: _reset,
          ),
          _buildOverflowAction(),
        ],
      ),
      children: [
        _buildSelectionInput(),
        const MinDivider(),
        _buildList(),
      ],
    );
  }

  Widget _buildOverflowAction() {
    return PopupMenuButton<String>(
      icon: const Icon(FormPage.moreMenuIcon),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: Strings.of(context).speciesCounterPageCreateTrip,
          onTap: _createTrip,
          enabled: _counts.isNotEmpty,
          child: Text(Strings.of(context).speciesCounterPageCreateTrip),
        ),
        PopupMenuItem<String>(
          value: Strings.of(context).speciesCounterPageAddToTrip,
          onTap: _showTripPicker,
          enabled: _counts.isNotEmpty,
          child: Text(Strings.of(context).speciesCounterPageAddToTrip),
        ),
      ],
    );
  }

  Widget _buildSelectionInput() {
    return ListItem(
      title: Text(Strings.of(context).speciesCounterPageSelect),
      trailing: RightChevronIcon(),
      onTap: () => push(
        context,
        SpeciesListPage(
          pickerSettings: ManageableListPagePickerSettings(
            initialValues:
                _speciesManager.list(_speciesController.value).toSet(),
            onPicked: (_, pickedItems) {
              // Remove items that are no longer picked.
              _counts.removeWhere((key, value) =>
                  !pickedItems.containsWhere((e) => e.id == key));

              // Add new picked items.
              for (var item in pickedItems) {
                _counts.putIfAbsent(item.id, () => 0);
              }

              _speciesController.value = pickedItems.map((e) => e.id).toSet();
              UserPreferenceManager.get.setSpeciesCounter(_counts);

              return true;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return StreamBuilder<String>(
      stream: UserPreferenceManager.get.stream,
      builder: (context, snapshot) => ValueListenableBuilder(
        valueListenable: _speciesController,
        builder: (_, __, ___) => Column(
          children: _speciesController.isEmpty
              ? []
              : _speciesManager
                  .listSortedByDisplayName(
                    context,
                    ids: _speciesController.value,
                  )
                  .map((e) => _buildRow(e))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildRow(Species species) {
    var title = _speciesManager.displayNameFromId(context, species.id);
    assert(isNotEmpty(title));

    return ListItem(
      padding: insetsSmall.copyWith(left: paddingDefault),
      title: Text(title ?? Strings.of(context).unknown),
      trailing: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            color: AppConfig.get.colorAppTheme,
            onPressed: _counts[species.id] == 0
                ? null
                : () => _incCount(species.id, -1),
          ),
          SizedBox(
            width: _textFieldSize,
            child: Center(
              child: Text(
                _counts[species.id]?.toString() ?? "0",
                style: stylePrimary(context),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: AppConfig.get.colorAppTheme,
            onPressed: () => _incCount(species.id, 1),
          ),
        ],
      ),
    );
  }

  void _reset() {
    for (var key in _counts.keys) {
      _counts[key] = 0;
    }
    UserPreferenceManager.get.setSpeciesCounter(_counts);
  }

  void _createTrip() {
    present(
      context,
      SaveTripPage.edit(Trip(
        id: randomId(),
        catchesPerSpecies: _counts.keys.map(
          (key) => Trip_CatchesPerEntity(
            entityId: key,
            value: _counts[key],
          ),
        ),
      )),
    );
  }

  void _showTripPicker() {
    present(
      context,
      TripListPage(
        pickerSettings: ManageableListPagePickerSettings.single(
          onPicked: (_, trip) {
            _onTripPicked(trip);
            return true;
          },
        ),
      ),
    );
  }

  Future<void> _onTripPicked(Trip? trip) async {
    if (trip == null) {
      return;
    }

    // Append current values.
    for (var perEntity in trip.catchesPerSpecies) {
      if (_counts.containsKey(perEntity.entityId)) {
        perEntity.value += _counts[perEntity.entityId] ?? 0;
      }
    }

    // Add new values.
    for (var entry in _counts.entries) {
      if (trip.catchesPerSpecies
          .containsWhere((e) => e.entityId == entry.key)) {
        continue;
      }
      trip.catchesPerSpecies.add(Trip_CatchesPerEntity(
        entityId: entry.key,
        value: entry.value,
      ));
    }

    await _tripManager.addOrUpdate(trip);

    safeUseContext(
      this,
      () => showNoticeSnackBar(
        context,
        Strings.of(context).speciesCounterPageTripUpdated(
          // Don't use displayName here (we don't want a date fallback
          // in this case).
          trip.hasName()
              ? trip.name
              : Strings.of(context).speciesCounterPageGeneralTripName,
        ),
      ),
    );
  }

  void _incCount(Id id, int incBy) {
    _setCount(id, (_counts[id] ?? 0) + incBy);
  }

  void _setCount(Id id, int value) {
    _counts[id] = value;
    UserPreferenceManager.get.setSpeciesCounter(_counts);
  }
}
