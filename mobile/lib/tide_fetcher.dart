import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/location_data_fetcher.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import '../../utils/string_utils.dart';
import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglers_log.pb.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'widgets/fetch_input_header.dart';
import 'wrappers/http_wrapper.dart';

class TideFetcher extends LocationDataFetcher<Tide?> {
  static const datum = "CD";
  static const _authority = "worldtides.info";
  static const _path = "/api/v3";

  final Log log;
  final TZDateTime dateTime;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  TideFetcher(
    this.dateTime,
    super._latLng, {
    this.log = const Log("TideFetcher"),
  });

  @override
  Future<FetchInputResult<Tide?>> fetch(BuildContext context) async {
    var strings = Strings.of(context);

    var result = await super.fetch(context);
    if (result != null) {
      return result;
    }

    if (latLng == null) {
      return FetchInputResult();
    }

    log.d("Fetching data...");

    var json = await _get();
    if (json == null) {
      return FetchInputResult();
    }

    // Known errors: {status: 400, error: No location found}
    var error = json["error"];
    if ("No location found" == error) {
      return FetchInputResult(
        data: null,
        errorMessage: strings.tideFetcherErrorNoLocationFound,
      );
    } else if (isNotEmpty(error)) {
      log.e(StackTrace.current, "Tide fetch error: $error");
      return FetchInputResult();
    }

    var heights = json["heights"];
    if (heights is! List) {
      log.e(StackTrace.current, "Tide fetch is missing heights");
      return FetchInputResult();
    }

    var extremes = json["extremes"];
    if (extremes is! List) {
      log.e(StackTrace.current, "Tide fetch is missing extremes");
      return FetchInputResult();
    }

    var tide = Tide(timeZone: dateTime.locationName);
    _parseJsonHeights(tide, heights);
    _parseJsonExtremes(tide, extremes);

    if (!tide.isValid) {
      log.e(StackTrace.current, "Fetched invalid tide value");
      return FetchInputResult();
    }

    return FetchInputResult(data: tide);
  }

  void _parseJsonHeights(Tide tide, List<dynamic> jsonHeights) {
    int? currentMsDifference;
    Tide_Height? currentTideHeight;

    _iterateTideList(jsonHeights, (timestamp, json) {
      var height = _heightFromJson(timestamp, json);
      if (height == null) {
        return;
      }

      // Add height to the collection of the days heights.
      tide.daysHeights.add(height);

      // Set/calculate all current data.
      var diff = (timestamp - dateTime.millisecondsSinceEpoch).abs();
      if (currentMsDifference == null || diff < currentMsDifference!) {
        currentMsDifference = diff;
        currentTideHeight = height;
      }
    });

    // Add the tide information for the input date.
    if (currentTideHeight == null) {
      return;
    }

    tide.height = currentTideHeight!;

    var indexOfCurrent = tide.daysHeights.indexOf(currentTideHeight!);
    if (indexOfCurrent > 0) {
      var prev = tide.daysHeights[indexOfCurrent - 1].value;

      // Not sure how to handle Low, High, and Slack tide since technically
      // they only happen for a second. Perhaps revisit at users' request.
      if (prev < currentTideHeight!.value) {
        tide.type = TideType.incoming;
      } else if (prev > currentTideHeight!.value) {
        tide.type = TideType.outgoing;
      }
    }
  }

  void _parseJsonExtremes(Tide tide, List<dynamic> jsonExtremes) {
    _iterateTideList(jsonExtremes, (timestamp, json) {
      var type = json["type"];
      if (type is! String) {
        return;
      }

      var height = _heightFromJson(timestamp, json);
      if (height == null) {
        return;
      }

      if (type == "Low") {
        if (tide.hasFirstLowHeight()) {
          tide.secondLowHeight = height;
        } else {
          tide.firstLowHeight = height;
        }
      }

      if (type == "High") {
        if (tide.hasFirstHighHeight()) {
          tide.secondHighHeight = height;
        } else {
          tide.firstHighHeight = height;
        }
      }
    });
  }

  /// Iterates the given JSON list. Assumes items in the list are sorted
  /// chronologically. Only the items on the current day are passed to [work].
  void _iterateTideList(
    List<dynamic> json,
    void Function(int timestamp, Map<String, dynamic> json) work,
  ) {
    for (var map in json) {
      var dt = intFromDynamic(map["dt"]);
      if (dt == null) {
        continue;
      }

      var timestamp = dt * Duration.millisecondsPerSecond;

      // WorldTides includes future data as well as the requested data. Filter
      // it out here.
      var heightDateTime = TZDateTime.fromMillisecondsSinceEpoch(
        dateTime.location,
        timestamp,
      );
      if (!isSameDay(dateTime, heightDateTime)) {
        continue;
      }

      work(timestamp, map);
    }
  }

  Tide_Height? _heightFromJson(int timestamp, Map<String, dynamic> json) {
    var height = doubleFromDynamic(json["height"]);
    if (height == null) {
      return null;
    }

    return Tide_Height(
      timestamp: Int64(timestamp),
      value: height,
    );
  }

  Future<Map<String, dynamic>?> _get() async {
    // Note that results are returned in seconds since epoch. If "localtime"
    // is included in the request, results will be fetched and returned in
    // local time. For now, use epoch; however, it's possible using local time
    // will result in a different number of high/low tides.
    var params = {
      "heights": null,
      "extremes": null,
      "datum": datum,
      "date": DateFormat("yyyy-MM-dd").format(dateTime),
      "lat": latLng!.latitudeString,
      "lon": latLng!.longitudeString,
      "key": PropertiesManager.get.worldTidesApiKey
    };

    return await getRestJson(
      _httpWrapper,
      Uri.https(_authority, _path, params),
      // Error responses result in HTTP error codes, but we still need to read
      // result.
      returnNullOnHttpError: false,
    );
  }
}
