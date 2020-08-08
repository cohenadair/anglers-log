import 'package:flutter/material.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/species_manager.dart';

class ReportView extends StatelessWidget {
  final List<EntityManager> managers;
  final VoidCallback onUpdate;
  final Widget Function(BuildContext) builder;

  ReportView({
    this.managers,
    @required this.onUpdate,
    @required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return EntityListenerBuilder(
      managers: [
        BaitManager.of(context),
        CatchManager.of(context),
        FishingSpotManager.of(context),
        SpeciesManager.of(context),
      ]..addAll(managers ?? []),
      onUpdate: onUpdate,
      builder: builder,
    );
  }
}