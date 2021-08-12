import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import 'app_manager.dart';
import 'bait_category_manager.dart';
import 'catch_manager.dart';
import 'custom_entity_manager.dart';
import 'entity_manager.dart';
import 'i18n/strings.dart';
import 'image_manager.dart';
import 'model/gen/anglerslog.pb.dart';
import 'named_entity_manager.dart';
import 'utils/protobuf_utils.dart';
import 'utils/string_utils.dart';

class BaitManager extends NamedEntityManager<Bait> {
  static BaitManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).baitManager;

  BaitCategoryManager get _baitCategoryManager =>
      appManager.baitCategoryManager;

  CatchManager get _catchManager => appManager.catchManager;

  CustomEntityManager get _customEntityManager =>
      appManager.customEntityManager;

  ImageManager get _imageManager => appManager.imageManager;

  BaitManager(AppManager app) : super(app) {
    app.baitCategoryManager.addListener(SimpleEntityListener(
      onDelete: _onDeleteBaitCategory,
    ));
  }

  @override
  Bait entityFromBytes(List<int> bytes) => Bait.fromBuffer(bytes);

  @override
  Id id(Bait bait) => bait.id;

  @override
  String name(Bait bait) => bait.name;

  @override
  String get tableName => "bait";

  @override
  bool matchesFilter(Id id, String? filter, [BuildContext? context]) {
    var bait = entity(id);
    if (bait == null) {
      return false;
    }

    if (super.matchesFilter(bait.id, filter) ||
        _variantsMatchesFilter(bait.variants, filter!) ||
        context == null ||
        _baitCategoryManager.matchesFilter(bait.baitCategoryId, filter) ||
        (bait.hasType() &&
            containsTrimmedLowerCase(
                bait.type.filterString(context), filter))) {
      return true;
    }

    return false;
  }

  @override
  Future<bool> addOrUpdate(
    Bait bait, {
    File? imageFile,
    bool compressImages = true,
    bool notify = true,
  }) async {
    if (imageFile != null) {
      var savedImages =
          await _imageManager.save([imageFile], compress: compressImages);
      if (savedImages.isNotEmpty) {
        bait.imageName = savedImages.first;
      }
    }

    return super.addOrUpdate(bait, notify: notify);
  }

  /// Returns true if any [BaitVariant] in [variants] matches [filter].
  bool _variantsMatchesFilter(List<BaitVariant> variants, String? filter) {
    if (isEmpty(filter)) {
      return true;
    }

    for (var variant in variants) {
      if (containsTrimmedLowerCase(variant.color, filter!) ||
          containsTrimmedLowerCase(variant.modelNumber, filter) ||
          containsTrimmedLowerCase(variant.size, filter) ||
          containsTrimmedLowerCase(variant.minDiveDepth.toString(), filter) ||
          containsTrimmedLowerCase(variant.maxDiveDepth.toString(), filter) ||
          containsTrimmedLowerCase(variant.description, filter) ||
          filterMatchesEntityValues(
              variant.customEntityValues, filter, _customEntityManager)) {
        return true;
      }
    }
    return false;
  }

  bool attachmentsMatchesFilter(Iterable<BaitAttachment> attachments,
      String? filter, BuildContext context) {
    for (var attachment in attachments) {
      if (matchesFilter(attachment.baitId, filter)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if the given [Bait] is a duplicate of an existing bait. A
  /// duplicate is defined as all equal properties, except [Bait.id], which
  /// must be different.
  bool duplicate(Bait rhs) {
    // Copy each bait and clear out the ID. The remaining fields can be compared
    // using the == operator for the copied objects.
    Bait clearId(Bait b) =>
        b.copyAndUpdate<Bait>((updates) => updates.clearId());

    var rhsCopy = clearId(rhs);
    var filteredList =
        list().where((lhs) => clearId(lhs) == rhsCopy && lhs.id != rhs.id);

    return filteredList.isNotEmpty;
  }

  /// Returns the number of [Catch] objects associated with the given [Bait] ID.
  int numberOfCatches(Id? baitId) {
    return numberOf<Catch>(baitId, _catchManager.list(),
        (cat) => cat.baits.where((e) => e.baitId == baitId).isNotEmpty);
  }

  /// Returns the number of [Catch] objects associated with the given
  /// [BaitVariant] ID.
  int numberOfVariantCatches(Id? variantId) {
    return numberOf<Catch>(variantId, _catchManager.list(),
        (cat) => cat.baits.where((e) => e.variantId == variantId).isNotEmpty);
  }

  /// Returns the total number of [CustomEntityValue] objects associated with
  /// [Bait] objects and [customEntityId].
  int numberOfCustomEntityValues(Id customEntityId) {
    var result = 0;

    for (var bait in list()) {
      if (bait.variants.isEmpty) {
        continue;
      }

      for (var variant in bait.variants) {
        if (variant.customEntityValues.isEmpty) {
          continue;
        }

        for (var value in variant.customEntityValues) {
          if (value.customEntityId == customEntityId) {
            result += 1;
          }
        }
      }
    }

    return result;
  }

  String? formatNameWithCategory(Id? baitId) {
    var bait = entity(baitId);
    if (bait == null) {
      return null;
    }

    var category = _baitCategoryManager.entity(bait.baitCategoryId);
    if (category != null) {
      return "${category.name} - ${bait.name}";
    }

    return bait.name;
  }

  /// Returns a list of all possible [BaitAttachment] instances created from
  /// each [Bait] object. A [BaitAttachment] will always have a
  /// [BaitAttachment.baitId] property, but may not have a
  /// [BaitAttachment.variantId] property if the [Bait] associated with
  /// [BaitAttachment.baitId] doesn't have any variants.
  List<BaitAttachment> baitAttachmentList() {
    var result = <BaitAttachment>[];

    var baits = list();
    for (var bait in baits) {
      if (bait.variants.isEmpty) {
        result.add(bait.toAttachment());
      } else {
        for (var variant in bait.variants) {
          result.add(variant.toAttachment());
        }
      }
    }

    return result;
  }

  BaitVariant? variant(Bait bait, Id variantId) {
    return bait.variants.firstWhereOrNull((e) => e.id == variantId);
  }

  BaitVariant? variantFromAttachment(BaitAttachment attachment) {
    var bait = entity(attachment.baitId);
    if (bait == null) {
      return null;
    }

    return variant(bait, attachment.variantId);
  }

  String? attachmentDisplayValue(
      BaitAttachment attachment, BuildContext context) {
    var bait = entity(attachment.baitId);
    if (bait == null) {
      return null;
    }

    var formattedBait = formatNameWithCategory(bait.id)!;
    var variant = variantFromAttachment(attachment);

    if (variant == null) {
      return formattedBait;
    } else {
      return "$formattedBait (${variantDisplayValue(
        variant,
        context,
        includeCustomValues: true,
      )})";
    }
  }

  List<String> attachmentsDisplayValues(
      Iterable<BaitAttachment> attachments, BuildContext context) {
    var result = <String>[];

    for (var attachment in attachments) {
      var displayValue = attachmentDisplayValue(attachment, context);
      if (isEmpty(displayValue)) {
        continue;
      }
      result.add(displayValue!);
    }

    return result;
  }

  String variantDisplayValue(
    BaitVariant variant,
    BuildContext context, {
    bool includeCustomValues = false,
  }) {
    var values = <String>[];

    if (variant.hasColor()) {
      values.add(variant.color);
    }

    if (variant.hasModelNumber()) {
      values.add(variant.modelNumber);
    }

    if (variant.hasSize()) {
      values.add(variant.size);
    }

    if (variant.hasMinDiveDepth() && variant.hasMaxDiveDepth()) {
      values.add("${variant.minDiveDepth.displayValue(context)} - "
          "${variant.minDiveDepth.displayValue(context)}");
    } else if (variant.hasMinDiveDepth()) {
      values.add(variant.minDiveDepth.displayValue(context));
    } else if (variant.hasMaxDiveDepth()) {
      values.add(variant.maxDiveDepth.displayValue(context));
    }

    if (includeCustomValues) {
      values.add(_customEntityManager.customValuesDisplayValue(
          variant.customEntityValues, context));
    }

    // BaitVariant.description is intentionally left out here so this display
    // value doesn't become too long.

    return formatList(values);
  }

  String deleteMessage(BuildContext context, Bait bait) {
    var numOfCatches = numberOfCatches(bait.id);
    var string = numOfCatches == 1
        ? Strings.of(context).baitListPageDeleteMessageSingular
        : Strings.of(context).baitListPageDeleteMessage;

    var category = _baitCategoryManager.entity(bait.baitCategoryId);
    String baitName;
    if (category == null) {
      baitName = bait.name;
    } else {
      baitName = "${bait.name} (${category.name})";
    }

    return format(string, [baitName, numOfCatches]);
  }

  String deleteVariantMessage(BuildContext context, BaitVariant variant) {
    var numOfCatches = numberOfVariantCatches(variant.id);
    var string = numOfCatches == 1
        ? Strings.of(context).saveBaitPageDeleteVariantSingular
        : Strings.of(context).saveBaitPageDeleteVariantPlural;
    return format(string, [numOfCatches]);
  }

  int Function(BaitAttachment, BaitAttachment) get baitAttachmentComparator =>
      (lhs, rhs) =>
          compareIgnoreCase(_sortValue(lhs.baitId), _sortValue(rhs.baitId));

  String _sortValue(Id baitId) {
    var bait = entity(baitId);
    if (bait == null) {
      return "";
    }

    return formatNameWithCategory(baitId) ?? bait.name;
  }

  void _onDeleteBaitCategory(BaitCategory baitCategory) {
    for (var bait in List<Bait>.from(
        list().where((bait) => baitCategory.id == bait.baitCategoryId))) {
      addOrUpdate(bait..clearBaitCategoryId());
    }
  }
}
