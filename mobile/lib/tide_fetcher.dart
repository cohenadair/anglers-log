import 'package:fixnum/fixnum.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/i18n/strings.dart';
import 'package:mobile/utils/date_time_utils.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:quiver/strings.dart';
import 'package:timezone/timezone.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/anglerslog.pb.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';
import 'utils/number_utils.dart';
import 'widgets/fetcher_input.dart';
import 'wrappers/http_wrapper.dart';

class TideFetcher {
  static const _authority = "worldtides.info";
  static const _path = "/api/v3";

  final _log = const Log("TideFetcher");

  final AppManager appManager;
  final TZDateTime dateTime;
  final LatLng? latLng;

  HttpWrapper get _httpWrapper => appManager.httpWrapper;

  PropertiesManager get _propertiesManager => appManager.propertiesManager;

  TideFetcher(this.appManager, this.dateTime, this.latLng);

  Future<FetchResult<Tide?>> fetch([Strings? strings]) async {
    if (latLng == null) {
      return FetchResult();
    }

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
      _log.e(StackTrace.current, "Tide fetch error: $error");
      return FetchResult();
    }

    var heights = json["heights"];
    if (heights is! List) {
      return FetchResult();
    }

    return FetchResult(data: _tideFromJsonHeights(heights));
  }

  Tide _tideFromJsonHeights(List<dynamic> jsonHeights) {
    double maxHeight = -double.maxFinite;
    double minHeight = double.maxFinite;

    int? currentMsDifference;
    int? highTimestamp;
    int? lowTimestamp;

    Tide_Height? currentTideHeight;

    var tide = Tide(timeZone: dateTime.locationName);

    // Assumes jsonHeights is sorted chronologically. Iterate all tide heights
    // throughout the day, recording the ones that meet the required criteria.
    for (var heightJson in jsonHeights) {
      var dt = intFromDynamic(heightJson["dt"]);
      var height = doubleFromDynamic(heightJson["height"]);

      // Not enough data.
      if (dt == null || height == null) {
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

      // Track the timestamps of the highest and lowest tide heights.
      if (highTimestamp == null || height > maxHeight) {
        maxHeight = height;
        highTimestamp = timestamp;
      }

      if (lowTimestamp == null || height < minHeight) {
        minHeight = height;
        lowTimestamp = timestamp;
      }

      // Add height to the collection of the days heights.
      var tideHeight = Tide_Height(
        timestamp: Int64(heightDateTime.millisecondsSinceEpoch),
        value: height,
      );
      tide.daysHeights.add(tideHeight);

      // Set/calculate all current data.
      var diff = (timestamp - dateTime.millisecondsSinceEpoch).abs();
      if (currentMsDifference == null || diff < currentMsDifference) {
        currentMsDifference = diff;
        currentTideHeight = tideHeight;
      }
    }

    // TODO: Replace with fetched "extremes"
    // Add the low and high tide times. Note that is is _possible_ for there to
    // be two high tides or two low tide times. This records the one with the
    // highest/lowest height value.
    if (lowTimestamp != null) {
      tide.firstLowTimestamp = Int64(lowTimestamp);
    }

    if (highTimestamp != null) {
      tide.firstHighTimestamp = Int64(highTimestamp);
    }

    // Add the tide information for the input date.
    if (currentTideHeight != null) {
      tide.height = currentTideHeight;

      var indexOfCurrent = tide.daysHeights.indexOf(currentTideHeight);
      if (indexOfCurrent > 0) {
        var prev = tide.daysHeights[indexOfCurrent - 1].value;

        // Not sure how to handle Low, High, and Slack tide since technically
        // they only happen for a second. Perhaps revisit at users' request.
        if (prev < currentTideHeight.value) {
          tide.type = TideType.incoming;
        } else if (prev > currentTideHeight.value) {
          tide.type = TideType.outgoing;
        }
      }
    }

    return tide;
  }

  Future<Map<String, dynamic>?> _get() async {
    var params = {
      "heights": null,
      "extremes": null,
      "plots": null,
      "date": DateFormat("yyyy-MM-dd").format(dateTime),
      "lat": latLng!.latitudeString,
      "lon": latLng!.longitudeString,
      "key": _propertiesManager.worldTidesApiKey
    };

    return await getRestJson(
      _httpWrapper,
      Uri.https(_authority, _path, params),
      returnNullOnHttpError: false,
    );
  }
}
