import 'package:adair_flutter_lib/utils/string.dart';
import 'package:flutter/material.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../angler_manager.dart';
import '../bait_manager.dart';
import '../fishing_spot_manager.dart';
import '../gear_manager.dart';
import '../method_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../species_manager.dart';
import '../water_clarity_manager.dart';
import '../widgets/field.dart';
import '../widgets/input_controller.dart';
import '../widgets/multi_measurement_input.dart';
import 'bool_utils.dart';
import 'protobuf_utils.dart';
import 'string_utils.dart';

// Unique IDs for each catch field. These are stored in the database and
// should not be changed.
final catchFieldIdAngler = Id()..uuid = "d1568a03-c34f-4840-b032-b0b3077847d3";
final catchFieldIdBait = Id()..uuid = "916e26ae-9448-4cef-b518-cfe4b4c1e5e8";
final catchFieldIdPeriod = Id()..uuid = "5ad83f1a-cc8f-48c4-a5bb-5394abd2e1f8";
final catchFieldIdFishingSpot = Id()
  ..uuid = "2e4e6124-6fc8-4a60-b8f3-b42debd97a99";
final catchFieldIdImages = Id()..uuid = "cb268ed0-59e2-469e-9279-a74e15ff42e8";
final catchFieldIdMethods = Id()..uuid = "b494335f-a9fb-4c1b-b4ec-40658645ef12";
final catchFieldIdSpecies = Id()..uuid = "7c4a5178-4e3b-4b97-ac69-b4a5439c4d94";
final catchFieldIdTimestamp = Id()
  ..uuid = "dbe382be-b219-4703-af11-a8ce16a191b7";
final catchFieldIdTimeZone = Id()
  ..uuid = "5d037f4b-0f24-4e4d-94a5-55130a729f1e";
final catchFieldIdFavorite = Id()
  ..uuid = "a12f6861-475f-475a-af29-c4fc6fe0a0bc";
final catchFieldIdCatchAndRelease = Id()
  ..uuid = "075fc6d5-b9b4-4377-b87d-a706287e1ffc";
final catchFieldIdSeason = Id()..uuid = "a2b00262-d130-45ce-b30b-f6e4f2d5baf5";
final catchFieldIdWaterClarity = Id()
  ..uuid = "ca035b3d-323c-44a6-a112-bede7177aeb2";
final catchFieldIdWaterDepth = Id()
  ..uuid = "c8a58e5f-19a1-430e-9d84-5a7b1bb96c3a";
final catchFieldIdWaterTemperature = Id()
  ..uuid = "eb66a49b-4add-43e1-b057-e95a5854fad8";
final catchFieldIdLength = Id()..uuid = "03ff0695-e160-4446-8f93-ba86d1ad1095";
final catchFieldIdWeight = Id()..uuid = "ca5e1447-7aa4-4508-870c-ce8dcd1d656e";
final catchFieldIdQuantity = Id()
  ..uuid = "8ed48dab-b5c3-4430-a702-aa336aea0f5a";
final catchFieldIdNotes = Id()..uuid = "a5ad6270-e131-40ad-b281-e1a4d838bf47";
final catchFieldIdAtmosphere = Id()
  ..uuid = "93f2a6bc-fb18-43a1-92c1-18c727440257";
final catchFieldIdTide = Id()..uuid = "5443a6ba-1860-4818-8b15-a6125121f451";
final catchFieldIdGear = Id()..uuid = "caa96186-382f-4da2-a762-40bcb20ef822";

/// Returns all catch fields, sorted by how they are rendered on a
/// [SaveCatchPage].
List<Field> allCatchFields(BuildContext context) {
  return [
    Field(
      id: catchFieldIdTimestamp,
      isRemovable: false,
      name: (context) => Strings.of(context).catchFieldDateTime,
      controller: CurrentDateTimeInputController(context),
    ),
    Field(
      id: catchFieldIdTimeZone,
      name: (context) => Strings.of(context).timeZoneInputLabel,
      description: (context) => Strings.of(context).timeZoneInputDescription,
      controller: TimeZoneInputController(context),
    ),
    Field(
      id: catchFieldIdPeriod,
      name: (context) => Strings.of(context).catchFieldPeriod,
      description: (context) => Strings.of(context).catchFieldPeriodDescription,
      controller: InputController<Period>(),
    ),
    Field(
      id: catchFieldIdSeason,
      name: (context) => Strings.of(context).catchFieldSeason,
      description: (context) => Strings.of(context).catchFieldSeasonDescription,
      controller: InputController<Season>(),
    ),
    Field(
      id: catchFieldIdSpecies,
      isRemovable: false,
      name: (context) => Strings.of(context).entityNameSpecies,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdBait,
      name: (context) => Strings.of(context).catchFieldBait,
      controller: SetInputController<BaitAttachment>(),
    ),
    Field(
      id: catchFieldIdGear,
      name: (context) => Strings.of(context).catchFieldGear,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: catchFieldIdImages,
      name: (context) => Strings.of(context).catchFieldImages,
      controller: ImagesInputController(),
    ),
    Field(
      id: catchFieldIdFishingSpot,
      name: (context) => Strings.of(context).catchFieldFishingSpot,
      description: (context) =>
          Strings.of(context).catchFieldFishingSpotDescription,
      controller: InputController<FishingSpot>(),
    ),
    Field(
      id: catchFieldIdAngler,
      name: (context) => Strings.of(context).catchFieldAngler,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdCatchAndRelease,
      name: (context) => Strings.of(context).catchFieldCatchAndRelease,
      description: (context) =>
          Strings.of(context).catchFieldCatchAndReleaseDescription,
      controller: BoolInputController(),
    ),
    Field(
      id: catchFieldIdFavorite,
      name: (context) => Strings.of(context).catchFieldFavorite,
      description: (context) =>
          Strings.of(context).catchFieldFavoriteDescription,
      controller: BoolInputController(),
    ),
    Field(
      id: catchFieldIdMethods,
      name: (context) => Strings.of(context).entityNameFishingMethods,
      description: (context) =>
          Strings.of(context).catchFieldMethodsDescription,
      controller: SetInputController<Id>(),
    ),
    Field(
      id: catchFieldIdAtmosphere,
      name: (context) => Strings.of(context).inputAtmosphere,
      controller: InputController<Atmosphere>(),
    ),
    Field(
      id: catchFieldIdTide,
      name: (context) => Strings.of(context).catchFieldTide,
      controller: InputController<Tide>(),
    ),
    Field(
      id: catchFieldIdWaterClarity,
      name: (context) => Strings.of(context).fieldWaterClarityLabel,
      controller: IdInputController(),
    ),
    Field(
      id: catchFieldIdWaterDepth,
      name: (context) => Strings.of(context).fieldWaterDepthLabel,
      controller: MultiMeasurementInputSpec.waterDepth(
        context,
      ).newInputController(),
    ),
    Field(
      id: catchFieldIdWaterTemperature,
      name: (context) => Strings.of(context).fieldWaterTemperatureLabel,
      controller: MultiMeasurementInputSpec.waterTemperature(
        context,
      ).newInputController(),
    ),
    Field(
      id: catchFieldIdLength,
      name: (context) => Strings.of(context).catchFieldLengthLabel,
      controller: MultiMeasurementInputSpec.length(
        context,
      ).newInputController(),
    ),
    Field(
      id: catchFieldIdWeight,
      name: (context) => Strings.of(context).catchFieldWeightLabel,
      controller: MultiMeasurementInputSpec.weight(
        context,
      ).newInputController(),
    ),
    Field(
      id: catchFieldIdQuantity,
      name: (context) => Strings.of(context).catchFieldQuantityLabel,
      description: (context) =>
          Strings.of(context).catchFieldQuantityDescription,
      controller: NumberInputController(),
    ),
    Field(
      id: catchFieldIdNotes,
      name: (context) => Strings.of(context).catchFieldNotesLabel,
      controller: TextInputController(),
    ),
  ];
}

/// Returns all catch fields sorted alphabetically.
List<Field> allCatchFieldsSorted(BuildContext context) {
  var fields = allCatchFields(context);
  fields.sort((lhs, rhs) => lhs.name!(context).compareTo(rhs.name!(context)));
  return fields;
}

bool catchFilterMatchesPeriod(BuildContext context, String filter, Catch cat) {
  return cat.hasPeriod() &&
      containsTrimmedLowerCase(cat.period.displayName(context), filter);
}

bool catchFilterMatchesSeason(BuildContext context, String filter, Catch cat) {
  return cat.hasSeason() &&
      containsTrimmedLowerCase(cat.season.displayName(context), filter);
}

bool catchFilterMatchesFavorite(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.hasIsFavorite() &&
      cat.isFavorite &&
      containsTrimmedLowerCase(Strings.of(context).keywordsFavorite, filter);
}

bool catchFilterMatchesCatchAndRelease(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.hasWasCatchAndRelease() &&
      cat.wasCatchAndRelease &&
      containsTrimmedLowerCase(
        Strings.of(context).keywordsCatchAndRelease,
        filter,
      );
}

bool catchFilterMatchesTimestamp(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.hasTimestamp() &&
      containsTrimmedLowerCase(cat.dateTimeSearchString(context), filter);
}

bool catchFilterMatchesWaterDepth(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.waterDepth.matchesFilter(context, filter);
}

bool catchFilterMatchesWaterTemperature(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.waterTemperature.matchesFilter(context, filter);
}

bool catchFilterMatchesLength(BuildContext context, String filter, Catch cat) {
  return cat.length.matchesFilter(context, filter);
}

bool catchFilterMatchesWeight(BuildContext context, String filter, Catch cat) {
  return cat.weight.matchesFilter(context, filter);
}

bool catchFilterMatchesQuantity(
  BuildContext context,
  String filter,
  Catch cat,
) {
  return cat.hasQuantity() &&
      containsTrimmedLowerCase(cat.quantity.toString(), filter);
}

bool catchFilterMatchesNotes(BuildContext context, String filter, Catch cat) {
  return cat.hasNotes() && containsTrimmedLowerCase(cat.notes, filter);
}

bool catchFilterMatchesAtmosphere(
  BuildContext context,
  String filter,
  Catch cat,
) {
  if (!cat.hasAtmosphere()) {
    return false;
  }
  return cat.atmosphere.matchesFilter(context, filter);
}

bool catchFilterMatchesTide(BuildContext context, String filter, Catch cat) {
  if (!cat.hasTide()) {
    return false;
  }

  var searchString = cat.tide.currentDisplayValue(context, useChipName: true);
  searchString += cat.tide.extremesDisplayValue(context);

  return isNotEmpty(searchString) &&
      containsTrimmedLowerCase(searchString, filter);
}

String formatNumberOfCatches(BuildContext context, int numberOfCatches) {
  return numberOfCatches == 1
      ? Strings.of(context).numberOfCatchesSingular
      : Strings.of(context).numberOfCatches(numberOfCatches);
}

/// Returns the catch fields that can be shown as a [CatchListItemModel]
/// subtitle, sorted alphabetically. Fields already shown in a catch list item
/// are excluded.
List<Field> catchListItemSubtitleFields(BuildContext context) {
  return allCatchFieldsSorted(context)..removeWhere(
    (field) =>
        field.id == catchFieldIdTimestamp ||
        field.id == catchFieldIdSpecies ||
        field.id == catchFieldIdImages ||
        field.id == catchFieldIdFavorite,
  );
}

/// Returns a single-line display value for [cat]'s [fieldId], or null if the
/// field isn't set or doesn't have a single-line display value (e.g. images).
String? catchFieldDisplayValue(BuildContext context, Catch cat, Id fieldId) {
  String? value;
  if (fieldId == catchFieldIdAngler) {
    value = AnglerManager.of(context).displayNameFromId(context, cat.anglerId);
  } else if (fieldId == catchFieldIdAtmosphere) {
    value = cat.hasAtmosphere()
        ? _atmosphereDisplayValue(context, cat.atmosphere)
        : null;
  } else if (fieldId == catchFieldIdBait) {
    value = formatList(
      BaitManager.of(context).attachmentsDisplayValues(context, cat.baits),
    );
  } else if (fieldId == catchFieldIdCatchAndRelease) {
    value = cat.hasWasCatchAndRelease()
        ? cat.wasCatchAndRelease.displayValue(context)
        : null;
  } else if (fieldId == catchFieldIdFavorite) {
    value = cat.hasIsFavorite() ? cat.isFavorite.displayValue(context) : null;
  } else if (fieldId == catchFieldIdFishingSpot) {
    value = FishingSpotManager.get.displayNameFromId(
      context,
      cat.fishingSpotId,
      includeBodyOfWater: true,
      useLatLngFallback: false,
    );
  } else if (fieldId == catchFieldIdGear) {
    value = formatList(
      GearManager.of(context).displayNamesFromIds(context, cat.gearIds),
    );
  } else if (fieldId == catchFieldIdLength) {
    value = cat.hasLength() ? cat.length.displayValue(context) : null;
  } else if (fieldId == catchFieldIdMethods) {
    value = formatList(
      MethodManager.of(context).displayNamesFromIds(context, cat.methodIds),
    );
  } else if (fieldId == catchFieldIdNotes) {
    value = cat.notes;
  } else if (fieldId == catchFieldIdPeriod) {
    value = cat.hasPeriod() ? cat.period.displayName(context) : null;
  } else if (fieldId == catchFieldIdQuantity) {
    value = cat.hasQuantity() ? cat.quantity.toString() : null;
  } else if (fieldId == catchFieldIdSeason) {
    value = cat.hasSeason() ? cat.season.displayName(context) : null;
  } else if (fieldId == catchFieldIdSpecies) {
    value = SpeciesManager.of(
      context,
    ).displayNameFromId(context, cat.speciesId);
  } else if (fieldId == catchFieldIdTide) {
    value = cat.hasTide() ? cat.tide.currentDisplayValue(context) : null;
  } else if (fieldId == catchFieldIdTimeZone) {
    // Format the name directly rather than using TimeZoneLocation, which
    // throws if the name doesn't exist in this device's time zone database.
    value = cat.timeZone.replaceAll("_", " ");
  } else if (fieldId == catchFieldIdWaterClarity) {
    value = WaterClarityManager.of(
      context,
    ).displayNameFromId(context, cat.waterClarityId);
  } else if (fieldId == catchFieldIdWaterDepth) {
    value = cat.hasWaterDepth() ? cat.waterDepth.displayValue(context) : null;
  } else if (fieldId == catchFieldIdWaterTemperature) {
    value = cat.hasWaterTemperature()
        ? cat.waterTemperature.displayValue(context)
        : null;
  } else if (fieldId == catchFieldIdWeight) {
    value = cat.hasWeight() ? cat.weight.displayValue(context) : null;
  }
  return isEmpty(value) ? null : value;
}

/// A single-line summary of [atmosphere]: its temperature and sky conditions.
/// The temperature is formatted the same as in [AtmosphereWrap].
String _atmosphereDisplayValue(BuildContext context, Atmosphere atmosphere) {
  return formatList([
    if (atmosphere.hasTemperature())
      atmosphere.temperature.displayValue(
        context,
        mainDecimalPlaces: MultiMeasurementInputSpec.airTemperature(
          context,
        ).mainValueDecimalPlaces?.call(context),
      ),
    if (atmosphere.skyConditions.isNotEmpty)
      SkyConditions.displayNameForList(context, atmosphere.skyConditions),
  ]);
}

class CatchListItemModel {
  late final String? imageName;
  late final String title;
  late final String subtitle;
  late final String? subtitle2;
  late final Widget trailing;

  /// Creates a model for [cat]. [subtitleFieldId] is the catch field shown as
  /// [subtitle2]. When null or the fishing spot field, the fishing spot is
  /// shown, falling back on the first bait.
  CatchListItemModel(BuildContext context, Catch cat, [Id? subtitleFieldId]) {
    var subtitle2 =
        subtitleFieldId == null || subtitleFieldId == catchFieldIdFishingSpot
        ? _fishingSpotThenBait(context, cat)
        : _fieldSubtitle(context, cat, subtitleFieldId);

    imageName = cat.imageNames.isNotEmpty ? cat.imageNames.first : null;
    title =
        SpeciesManager.of(context).entity(cat.speciesId)?.name ??
        Strings.of(context).unknownSpecies;
    subtitle = cat.displayTimestamp(context);
    trailing = CatchFavoriteStar(cat);
    this.subtitle2 = isEmpty(subtitle2) ? null : subtitle2;
  }

  static String? _fishingSpotThenBait(BuildContext context, Catch cat) {
    var fishingSpotManager = FishingSpotManager.get;

    String? result;
    var fishingSpot = fishingSpotManager.entity(cat.fishingSpotId);
    if (fishingSpot != null) {
      // Use fishing spot name as subtitle if available.
      result = fishingSpotManager.displayName(
        context,
        fishingSpot,
        useLatLngFallback: false,
        includeBodyOfWater: true,
      );
    }

    if (isEmpty(result) && cat.baits.isNotEmpty) {
      // Fallback on bait as a subtitle.
      var formattedName = BaitManager.of(
        context,
      ).attachmentDisplayValue(context, cat.baits.first);
      if (isNotEmpty(formattedName)) {
        result = formattedName;
      }
    }

    return result;
  }

  /// Returns the value of the given catch field, or null if [fieldId] isn't a
  /// supported subtitle field. When the field isn't set, "<field name>: -" is
  /// returned so the user knows what the subtitle represents.
  static String? _fieldSubtitle(BuildContext context, Catch cat, Id fieldId) {
    var label = _subtitleLabels(context)[fieldId];
    if (label == null) {
      return null;
    }

    var (name, showsName) = label;
    var value = catchFieldDisplayValue(context, cat, fieldId);
    if (value == null) {
      return Strings.of(
        context,
      ).catchListItemFieldValue(name, Strings.of(context).catchListItemNotSet);
    }
    return showsName
        ? Strings.of(context).catchListItemFieldValue(name, value)
        : value;
  }

  /// Each supported subtitle field's name, and whether the name is always
  /// shown. Names are always shown for values that aren't self-explanatory
  /// (e.g. "Yes" or "4").
  static Map<Id, (String, bool)> _subtitleLabels(BuildContext context) {
    return {
      catchFieldIdAngler: (Strings.of(context).catchFieldAngler, false),
      catchFieldIdAtmosphere: (Strings.of(context).inputAtmosphere, false),
      catchFieldIdBait: (Strings.of(context).catchFieldBait, false),
      catchFieldIdCatchAndRelease: (
        Strings.of(context).catchFieldCatchAndRelease,
        true,
      ),
      catchFieldIdGear: (Strings.of(context).catchFieldGear, false),
      catchFieldIdLength: (Strings.of(context).catchFieldLengthLabel, false),
      catchFieldIdMethods: (
        Strings.of(context).entityNameFishingMethods,
        false,
      ),
      catchFieldIdNotes: (Strings.of(context).catchFieldNotesLabel, false),
      catchFieldIdPeriod: (Strings.of(context).catchFieldPeriod, false),
      catchFieldIdQuantity: (Strings.of(context).catchFieldQuantityLabel, true),
      catchFieldIdSeason: (Strings.of(context).catchFieldSeason, false),
      catchFieldIdTide: (Strings.of(context).catchFieldTide, false),
      catchFieldIdTimeZone: (Strings.of(context).timeZoneInputLabel, false),
      catchFieldIdWaterClarity: (
        Strings.of(context).catchListItemWaterClarity,
        true,
      ),
      catchFieldIdWaterDepth: (
        Strings.of(context).catchListItemWaterDepth,
        true,
      ),
      catchFieldIdWaterTemperature: (
        Strings.of(context).fieldWaterTemperatureLabel,
        true,
      ),
      catchFieldIdWeight: (Strings.of(context).catchFieldWeightLabel, false),
    };
  }
}

int catchQuantity(Catch cat) => cat.hasQuantity() ? cat.quantity : 1;
