import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'widgets/fetch_input_header.dart';
import 'wrappers/http_wrapper.dart';

class TideFetcher {
  static const _authority = "worldtides.info";
  static const _path = "/api/v3";

  final Log log;
  final AppManager appManager;
  final TZDateTime dateTime;
  final LatLng? latLng;

  HttpWrapper get _httpWrapper => appManager.httpWrapper;

  PropertiesManager get _propertiesManager => appManager.propertiesManager;

  TideFetcher(
    this.appManager,
    this.dateTime,
    this.latLng, {
    this.log = const Log("TideFetcher"),
  });

  Future<FetchResult<Tide?>> fetch([Strings? strings]) async {
    if (latLng == null) {
      return FetchResult();
    }

    log.d("Fetching data...");

    var json = await _get();
    if (json == null) {
      return FetchResult();
    }

    // Known errors: {status: 400, error: No location found}
    var error = json["error"];
    if ("No location found" == error) {
      return FetchResult(
        data: null,
        errorMessage: strings?.tideFetcherErrorNoLocationFound,
      );
    } else if (isNotEmpty(error)) {
      log.e(StackTrace.current, "Tide fetch error: $error");
      return FetchResult();
    }

    var heights = json["heights"];
    if (heights is! List) {
      log.e(StackTrace.current, "Tide fetch is missing heights");
      return FetchResult();
    }

    var extremes = json["extremes"];
    if (extremes is! List) {
      log.e(StackTrace.current, "Tide fetch is missing extremes");
      return FetchResult();
    }

    var tide = Tide(timeZone: dateTime.locationName);
    _parseJsonHeights(tide, heights);
    _parseJsonExtremes(tide, extremes);

    if (!tide.isValid) {
      log.e(StackTrace.current, "Fetched invalid tide value");
      return FetchResult();
    }

    return FetchResult(data: tide);
  }

  void _parseJsonHeights(Tide tide, List<dynamic> jsonHeights) {
    int? currentMsDifference;
    Tide_Height? currentTideHeight;

    _iterateTideList(jsonHeights, (timestamp, json) {
      var height = doubleFromDynamic(json["height"]);
      if (height == null) {
        return;
      }
      // Add height to the collection of the days heights.
      var tideHeight = Tide_Height(
        timestamp: Int64(timestamp),
        value: height,
      );
      tide.daysHeights.add(tideHeight);

      // Set/calculate all current data.
      var diff = (timestamp - dateTime.millisecondsSinceEpoch).abs();
      if (currentMsDifference == null || diff < currentMsDifference!) {
        currentMsDifference = diff;
        currentTideHeight = tideHeight;
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

      if (type == "Low") {
        if (tide.hasFirstLowTimestamp()) {
          tide.secondLowTimestamp = Int64(timestamp);
        } else {
          tide.firstLowTimestamp = Int64(timestamp);
        }
      }

      if (type == "High") {
        if (tide.hasFirstHighTimestamp()) {
          tide.secondHighTimestamp = Int64(timestamp);
        } else {
          tide.firstHighTimestamp = Int64(timestamp);
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

  Future<Map<String, dynamic>?> _get() async {
    var params = {
      "heights": null,
      "extremes": null,
      "date": DateFormat("yyyy-MM-dd").format(dateTime),
      "lat": latLng!.latitudeString,
      "lon": latLng!.longitudeString,
      "key": _propertiesManager.worldTidesApiKey
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
