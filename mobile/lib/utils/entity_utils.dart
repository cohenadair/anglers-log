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
import 'package:mobile/pages/pro_page.dart';
import 'package:mobile/pages/save_angler_page.dart';
import 'package:mobile/pages/save_bait_category_page.dart';
import 'package:mobile/pages/save_bait_page.dart';
import 'package:mobile/pages/save_body_of_water_page.dart';
import 'package:mobile/pages/save_custom_entity_page.dart';
import 'package:mobile/pages/save_method_page.dart';
import 'package:mobile/pages/save_species_page.dart';
import 'package:mobile/pages/save_trip_page.dart';
import 'package:mobile/pages/save_water_clarity_page.dart';
import 'package:mobile/pages/species_list_page.dart';
import 'package:mobile/pages/trip_list_page.dart';
import 'package:mobile/pages/water_clarity_list_page.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/widgets/widget.dart';

import '../pages/gear_list_page.dart';
import '../pages/gps_trail_list_page.dart';
import '../pages/save_gear_page.dart';
import 'page_utils.dart';

@immutable
class EntitySpec {
  final IconData icon;
  final String Function(BuildContext) singularName;
  final String Function(BuildContext) pluralName;
  final Widget Function(BuildContext) listPageBuilder;
  final void Function(BuildContext) presentSavePage;
  final bool Function(BuildContext) isTracked;
  final bool canAdd;

  const EntitySpec({
    required this.singularName,
    required this.pluralName,
    required this.icon,
    required this.listPageBuilder,
    required this.presentSavePage,
    required this.isTracked,
    required this.canAdd,
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
  gearEntitySpec,
  gpsTrailEntitySpec,
  speciesEntitySpec,
  tripsEntitySpec,
  waterClaritiesEntitySpec,
];

var anglersEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameAngler,
  pluralName: (context) => Strings.of(context).entityNameAnglers,
  icon: iconAngler,
  listPageBuilder: (_) => const AnglerListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveAnglerPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingAnglers,
  canAdd: true,
);

var baitCategoriesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBaitCategory,
  pluralName: (context) => Strings.of(context).entityNameBaitCategories,
  icon: iconBaitCategories,
  listPageBuilder: (_) => const BaitCategoryListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveBaitCategoryPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingBaits,
  canAdd: true,
);

var baitsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBait,
  pluralName: (context) => Strings.of(context).entityNameBaits,
  icon: iconBait,
  listPageBuilder: (_) => const BaitListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveBaitPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingBaits,
  canAdd: true,
);

var bodiesOfWaterEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameBodyOfWater,
  pluralName: (context) => Strings.of(context).entityNameBodiesOfWater,
  icon: iconBodyOfWater,
  listPageBuilder: (_) => const BodyOfWaterListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveBodyOfWaterPage()),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingFishingSpots,
  canAdd: true,
);

var catchesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameCatch,
  pluralName: (context) => Strings.of(context).entityNameCatches,
  icon: iconCatch,
  listPageBuilder: (_) => const CatchListPage(),
  presentSavePage: (context) => present(context, const AddCatchJourney()),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingFishingSpots,
  canAdd: true,
);

var customFieldsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameCustomField,
  pluralName: (context) => Strings.of(context).entityNameCustomFields,
  icon: iconCustomField,
  listPageBuilder: (_) => const CustomEntityListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, true, const SaveCustomEntityPage()),
  isTracked: (_) => true,
  canAdd: true,
);

var fishingMethodsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameFishingMethod,
  pluralName: (context) => Strings.of(context).entityNameFishingMethods,
  icon: iconMethod,
  listPageBuilder: (_) => const MethodListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveMethodPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingMethods,
  canAdd: true,
);

var gearEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameGear,
  pluralName: (context) => Strings.of(context).entityNameGear,
  icon: iconGear,
  listPageBuilder: (_) => const GearListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveGearPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingGear,
  canAdd: true,
);

var gpsTrailEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameGpsTrail,
  pluralName: (context) => Strings.of(context).entityNameGpsTrails,
  icon: iconGpsTrail,
  listPageBuilder: (_) => const GpsTrailListPage(),
  presentSavePage: (context) {
    assert(false, "Save page does not exist for GPS trails");
  },
  isTracked: (_) => true,
  canAdd: false,
);

var speciesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameSpecies,
  pluralName: (context) => Strings.of(context).entityNameSpecies,
  icon: iconSpecies,
  listPageBuilder: (_) => const SpeciesListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveSpeciesPage()),
  isTracked: (context) => UserPreferenceManager.of(context).isTrackingSpecies,
  canAdd: true,
);

var tripsEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameTrip,
  pluralName: (context) => Strings.of(context).entityNameTrips,
  icon: iconTrip,
  listPageBuilder: (_) => const TripListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveTripPage()),
  isTracked: (_) => true,
  canAdd: true,
);

var waterClaritiesEntitySpec = EntitySpec(
  singularName: (context) => Strings.of(context).entityNameWaterClarity,
  pluralName: (context) => Strings.of(context).entityNameWaterClarities,
  icon: iconWaterClarity,
  listPageBuilder: (_) => const WaterClarityListPage(),
  presentSavePage: (context) =>
      _presentSavePage(context, false, const SaveWaterClarityPage()),
  isTracked: (context) =>
      UserPreferenceManager.of(context).isTrackingWaterClarities,
  canAdd: true,
);

void _presentSavePage(BuildContext context, bool isPro, Widget savePage) {
  present(
    context,
    isPro && SubscriptionManager.of(context).isFree
        ? const ProPage()
        : savePage,
  );
}
