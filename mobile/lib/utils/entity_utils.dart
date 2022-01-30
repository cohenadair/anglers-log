import 'package:flutter/material.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/pages/add_catch_journey.dart';
import 'package:mobile/pages/angler_list_page.dart';
import 'package:mobile/pages/bait_category_list_page.dart';
import 'package:mobile/pages/bait_list_page.dart';
import 'package:mobile/pages/body_of_water_list_page.dart';
import 'package:mobile/pages/catch_list_page.dart';
import 'package:mobile/pages/custom_entity_list_page.dart';
import 'package:mobile/pages/method_list_page.dart';
import 'package:mobile/pages/save_angler_page.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/pages/save_body_of_water_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/pages/save_method_page.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/pages/save_water_clarity_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/widget.dart';

@immutable
class EntitySpec {
  final IconData icon;
  final String Function(BuildContext) singularName;
  final String Function(BuildContext) pluralName;
  final Widget Function(BuildContext) listPageBuilder;
  final Widget Function(BuildContext) savePageBuilder;
  final bool Function(BuildContext) isTracked;
  final bool isProOnly;

  const EntitySpec({
    required this.singularName,
    required this.pluralName,
    required this.icon,
    required this.listPageBuilder,
    required this.savePageBuilder,
    required this.isTracked,
    this.isProOnly = false,
  });
}

var allEntitySpecs = [
  anglersEntitySpec,
  baitCategoriesEntitySpec,
  baitsEntitySpec,
  bodiesOfWaterEntitySpec,
  catchesEntitySpec,
  customFieldsEntitySpec,
  fishingMethodsEntitySpec,
  speciesEntitySpec,
  tripsEntitySpec,
  waterClaritiesEntitySpec,
];

var anglersEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameAngler,
  pluralName: (context) => Strings.of(context).entityNameAnglers,
  icon: iconAngler,
  listPageBuilder: (_) => const AnglerListPage(),
  savePageBuilder: (_) => const SaveAnglerPage(),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingAnglers,
);

var baitCategoriesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBaitCategory,
  pluralName: (context) => Strings.of(context).entityNameBaitCategories,
  icon: iconBaitCategories,
  listPageBuilder: (_) => const BaitCategoryListPage(),
  savePageBuilder: (_) => const SaveBaitCategoryPage(),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingBaits,
);

var baitsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBait,
  pluralName: (context) => Strings.of(context).entityNameBaits,
  icon: iconBait,
  listPageBuilder: (_) => const BaitListPage(),
  savePageBuilder: (_) => const SaveBaitPage(),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingBaits,
);

var bodiesOfWaterEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBodyOfWater,
  pluralName: (context) => Strings.of(context).entityNameBodiesOfWater,
  icon: iconBodyOfWater,
  listPageBuilder: (_) => const BodyOfWaterListPage(),
  savePageBuilder: (_) => const SaveBodyOfWaterPage(),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingFishingSpots,
);

var catchesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameCatch,
  pluralName: (context) => Strings.of(context).entityNameCatches,
  icon: iconCatch,
  listPageBuilder: (_) => const CatchListPage(),
  savePageBuilder: (_) => const AddCatchJourney(),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingFishingSpots,
);

var customFieldsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameCustomField,
  pluralName: (context) => Strings.of(context).entityNameCustomFields,
  icon: iconCustomField,
  listPageBuilder: (_) => const CustomEntityListPage(),
  savePageBuilder: (_) => const SaveCustomEntityPage(),
  isTracked: (_) => true,
  isProOnly: true,
);

var fishingMethodsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameFishingMethod,
  pluralName: (context) => Strings.of(context).entityNameFishingMethods,
  icon: iconMethod,
  listPageBuilder: (_) => const MethodListPage(),
  savePageBuilder: (_) => const SaveMethodPage(),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingMethods,
);

var speciesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameSpecies,
  pluralName: (context) => Strings.of(context).entityNameSpecies,
  icon: iconSpecies,
  listPageBuilder: (_) => const SpeciesListPage(),
  savePageBuilder: (_) => const SpeciesListPage(),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingSpecies,
);

var tripsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameTrip,
  pluralName: (context) => Strings.of(context).entityNameTrips,
  icon: iconTrip,
  listPageBuilder: (_) => const TripListPage(),
  savePageBuilder: (_) => const SaveTripPage(),
  isTracked: (_) => true,
);

var waterClaritiesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameWaterClarity,
  pluralName: (context) => Strings.of(context).entityNameWaterClarities,
  icon: iconWaterClarity,
  listPageBuilder: (_) => const WaterClarityListPage(),
  savePageBuilder: (_) => const SaveWaterClarityPage(),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingWaterClarities,
);
