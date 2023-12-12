import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as map;
import 'package:mobile/angler_manager.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/atmosphere_fetcher.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/gear_manager.dart';
import 'package:mobile/gps_trail_manager.dart';
import 'package:mobile/log.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/report_manager.dart';
import 'package:mobile/custom_entity_manager.dart';
import 'package:mobile/database/legacy_importer.dart';
import 'package:mobile/entity_manager.dart';
import 'package:mobile/method_manager.dart';
import 'package:mobile/preference_manager.dart';
import 'package:mobile/subscription_manager.dart';
import 'package:mobile/local_database_manager.dart';
import 'package:mobile/fishing_spot_manager.dart';
import 'package:mobile/image_manager.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/properties_manager.dart';
import 'package:mobile/species_manager.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/utils/validator.dart';
import 'package:mobile/water_clarity_manager.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/wrappers/crashlytics_wrapper.dart';
import 'package:mobile/wrappers/csv_wrapper.dart';
import 'package:mobile/wrappers/device_info_wrapper.dart';
import 'package:mobile/wrappers/drive_api_wrapper.dart';
import 'package:mobile/wrappers/exif_wrapper.dart';
import 'package:mobile/wrappers/file_picker_wrapper.dart';
import 'package:mobile/wrappers/geolocator_wrapper.dart';
import 'package:mobile/wrappers/google_sign_in_wrapper.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/image_picker_wrapper.dart';
import 'package:mobile/wrappers/in_app_review_wrapper.dart';
import 'package:mobile/wrappers/isolates_wrapper.dart';
import 'package:mobile/wrappers/native_time_zone_wrapper.dart';
import 'package:mobile/wrappers/purchases_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:mobile/wrappers/photo_manager_wrapper.dart';
import 'package:mobile/wrappers/services_wrapper.dart';
import 'package:mobile/wrappers/share_plus_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:native_exif/native_exif.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../test_utils.dart';
import 'mocks.mocks.dart';

// TODO: Remove generation - https://github.com/dart-lang/mockito/issues/347

Trip_CatchesPerEntity newInputItemShim(dynamic pickerItem) =>
    Trip_CatchesPerEntity();

@GenerateMocks([AnglerManager])
@GenerateMocks([AndroidBuildVersion])
@GenerateMocks([AndroidDeviceInfo])
@GenerateMocks([AppManager])
@GenerateMocks([], customMocks: [MockSpec<map.ArgumentCallbacks>()])
@GenerateMocks([AtmosphereFetcher])
@GenerateMocks([AuthClient])
@GenerateMocks([BackupRestoreManager])
@GenerateMocks([BaitCategoryManager])
@GenerateMocks([BaitManager])
@GenerateMocks([BodyOfWaterManager])
@GenerateMocks([CatchManager])
@GenerateMocks([CustomEntityManager])
@GenerateMocks([drive.DriveApi])
@GenerateMocks([drive.FileList])
@GenerateMocks([drive.FilesResource])
@GenerateMocks([DriveApiWrapper])
@GenerateMocks([Exif])
@GenerateMocks([FishingSpotManager])
@GenerateMocks([GearManager])
@GenerateMocks([GeolocatorWrapper])
@GenerateMocks([GoogleSignIn])
@GenerateMocks([GoogleSignInAccount])
@GenerateMocks([GpsTrailManager])
@GenerateMocks([ImageManager])
@GenerateMocks([], customMocks: [MockSpec<InputController>()])
@GenerateMocks([IOSink])
@GenerateMocks([LocalDatabaseManager])
@GenerateMocks([LocationMonitor])
@GenerateMocks([], customMocks: [
  MockSpec<Log>(unsupportedMembers: {
    Symbol("sync"),
    Symbol("async"),
  })
])
@GenerateMocks([MethodManager])
@GenerateMocks([PlatformException])
@GenerateMocks([PollManager])
@GenerateMocks([PreferenceManager])
@GenerateMocks([PropertiesManager])
@GenerateMocks([ReportManager])
@GenerateMocks([SpeciesManager])
@GenerateMocks([SubscriptionManager])
@GenerateMocks([TimeManager])
@GenerateMocks([TimeZoneLocation])
@GenerateMocks([TripManager])
@GenerateMocks([UserPreferenceManager])
@GenerateMocks([WaterClarityManager])
@GenerateMocks([CrashlyticsWrapper])
@GenerateMocks([CsvWrapper])
@GenerateMocks([DeviceInfoWrapper])
@GenerateMocks([ExifWrapper])
@GenerateMocks([FilePickerWrapper])
@GenerateMocks([], customMocks: [MockSpec<GlobalKey>()])
@GenerateMocks([GoogleSignInWrapper])
@GenerateMocks([HttpWrapper])
@GenerateMocks([ImageCompressWrapper])
@GenerateMocks([InAppReviewWrapper])
@GenerateMocks([IoWrapper])
@GenerateMocks([IsolatesWrapper])
@GenerateMocks([NativeTimeZoneWrapper])
@GenerateMocks([map.MapboxMapController])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([PathProviderWrapper])
@GenerateMocks([PermissionHandlerWrapper])
@GenerateMocks([PhotoManagerWrapper])
@GenerateMocks([PurchasesWrapper])
@GenerateMocks([ServicesWrapper])
@GenerateMocks([SharedPreferencesWrapper])
@GenerateMocks([SharePlusWrapper])
@GenerateMocks([UrlLauncherWrapper])
@GenerateMocks([AssetPathEntity])
@GenerateMocks([Batch])
@GenerateMocks([Completer])
@GenerateMocks([Database])
@GenerateMocks([Directory])
@GenerateMocks([EntitlementInfo])
@GenerateMocks([EntitlementInfos])
@GenerateMocks([], customMocks: [MockSpec<EntityListener>()])
@GenerateMocks([FileSystemEntity])
@GenerateMocks([LegacyImporter])
@GenerateMocks([LogInResult])
@GenerateMocks([MethodChannel])
@GenerateMocks([NameValidator])
@GenerateMocks([NavigatorObserver])
@GenerateMocks([Offering])
@GenerateMocks([Offerings])
@GenerateMocks([Package])
@GenerateMocks([PackageInfo])
@GenerateMocks([StoreProduct])
@GenerateMocks([map.Symbol])
@GenerateMocks([CustomerInfo])
@GenerateMocks([], customMocks: [
  MockSpec<QuantityPickerInputDelegate>(
    fallbackGenerators: {
      #newInputItem: newInputItemShim,
    },
  )
])
@GenerateMocks([Response])
@GenerateMocks([], customMocks: [MockSpec<StreamSubscription>()])
// @GenerateMocks can't generate mock because of an internal type used in API.
class MockFile extends Mock implements File {
  @override
  int get hashCode =>
      (super.noSuchMethod(Invocation.getter(#hashCode), returnValue: 0) as int);

  // Mockito can't stub operator overrides.
  @override
  bool operator ==(Object other) => false;

  @override
  String get path =>
      (super.noSuchMethod(Invocation.getter(#path), returnValue: "") as String);

  @override
  Future<bool> exists() => (super.noSuchMethod(Invocation.method(#exists, []),
      returnValue: Future.value(false)) as Future<bool>);

  @override
  bool existsSync() => (super.noSuchMethod(Invocation.method(#existsSync, []),
      returnValue: false) as bool);

  @override
  Future<Uint8List> readAsBytes() => (super.noSuchMethod(
      Invocation.method(#readAsBytes, []),
      returnValue: Future.value(Uint8List.fromList([]))) as Future<Uint8List>);

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => (super.noSuchMethod(
      Invocation.method(#openRead, [
        start,
        end,
      ]),
      returnValue: Stream.value(Uint8List.fromList([]))) as Stream<Uint8List>);

  @override
  int lengthSync() =>
      (super.noSuchMethod(Invocation.method(#lengthSync, []), returnValue: 0)
          as int);

  @override
  IOSink openWrite({
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) =>
      super.noSuchMethod(
        Invocation.method(#openWrite, [], {
          #mode: mode,
          #encoding: encoding,
        }),
        returnValue: IOSink(StreamController()),
      );

  @override
  Future<File> writeAsBytes(
    List<int>? bytes, {
    bool? flush,
    FileMode? mode,
  }) {
    return (super.noSuchMethod(
        Invocation.method(#writeAsBytes, [
          bytes
        ], {
          #flush: flush,
          #mode: mode,
        }),
        returnValue: Future.value(File(""))) as Future<File>);
  }

  @override
  Future<File> writeAsString(
    String? contents, {
    FileMode? mode,
    Encoding? encoding,
    bool? flush,
  }) {
    return (super.noSuchMethod(
        Invocation.method(#writeAsString, [
          contents
        ], {
          #flush: flush,
          #mode: mode,
          #encoding: encoding,
        }),
        returnValue: Future.value(File(""))) as Future<File>);
  }

  @override
  Future<FileSystemEntity> delete({bool? recursive = false}) {
    return (super.noSuchMethod(
        Invocation.method(#delete, [], {
          #recursive: recursive,
        }),
        returnValue: Future.value(File(""))) as Future<FileSystemEntity>);
  }

  @override
  void deleteSync({bool? recursive = false}) {
    super.noSuchMethod(Invocation.method(#deleteSync, [], {
      #recursive: recursive,
    }));
  }
}

// @GenerateMocks produces a conflict where the wrong PickedFile class is used
// (one from unsupported.dart and one from io.dart in the image_picker library).
class MockImagePickerWrapper extends Mock implements ImagePickerWrapper {
  @override
  Future<XFile?> pickImage(ImageSource? source) =>
      super.noSuchMethod(Invocation.method(#getImage, [source]),
          returnValue: Future.value(null)) as Future<XFile?>;
}

// @GenerateMocks can't generate mock because of an internal type used in API.
class MockStream<T> extends Mock implements Stream<T> {
  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return (super.noSuchMethod(
      Invocation.method(#listen, [
        onData
      ], {
        #onError: onError,
        #onDone: onDone,
        #cancelOnError: cancelOnError,
      }),
      returnValue: MockStreamSubscription<T>(),
    ) as StreamSubscription<T>);
  }

  @override
  Future<List<T>> toList() => super.noSuchMethod(Invocation.method(#list, []),
      returnValue: Future.value(<T>[])) as Future<List<T>>;
}

// Mockito can't stub the == operator, which makes it impossible to use mocks
// created with Mockito in a Set.
// https://github.com/dart-lang/mockito/issues/365
// ignore: must_be_immutable
class MockAssetEntity extends AssetEntity {
  final String fileName;
  final DateTime? dateTime;
  final LatLng? latLngAsync;

  int latLngAsyncCalls = 0;
  Future<File?>? originFileStub;

  MockAssetEntity({
    required this.fileName,
    String? id,
    this.dateTime,
    this.latLngAsync,
    LatLng? latLngLegacy,
  }) : super(
          id: id ?? fileName,
          typeInt: AssetType.image.index,
          width: 50,
          height: 50,
          latitude: latLngLegacy?.latitude,
          longitude: latLngLegacy?.longitude,
        );

  @override
  DateTime get createDateTime => dateTime ?? now();

  @override
  Future<Uint8List?> get thumbnailData =>
      Future.value(File("test/resources/$fileName").readAsBytesSync());

  @override
  Future<LatLng> latlngAsync() {
    latLngAsyncCalls++;
    return Future.value(latLngAsync ?? const LatLng(latitude: 0, longitude: 0));
  }

  @override
  Future<File?> get originFile =>
      originFileStub ?? Future.value(File("test/resources/$fileName"));
}

void main() {}
