import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapbox_gl/mapbox_gl.dart' as map;
import 'package:mobile/angler_manager.dart';
import 'package:mobile/app_manager.dart';
import 'package:mobile/app_preference_manager.dart';
import 'package:mobile/atmosphere_fetcher.dart';
import 'package:mobile/auth_manager.dart';
import 'package:mobile/bait_category_manager.dart';
import 'package:mobile/bait_manager.dart';
import 'package:mobile/body_of_water_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
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
import 'package:mobile/widgets/quantity_picker_input.dart';
import 'package:mobile/wrappers/file_picker_wrapper.dart';
import 'package:mobile/wrappers/firebase_auth_wrapper.dart';
import 'package:mobile/wrappers/firebase_storage_wrapper.dart';
import 'package:mobile/wrappers/firebase_wrapper.dart';
import 'package:mobile/wrappers/firestore_wrapper.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:mobile/wrappers/image_compress_wrapper.dart';
import 'package:mobile/wrappers/image_picker_wrapper.dart';
import 'package:mobile/wrappers/purchases_wrapper.dart';
import 'package:mobile/wrappers/io_wrapper.dart';
import 'package:mobile/wrappers/package_info_wrapper.dart';
import 'package:mobile/wrappers/path_provider_wrapper.dart';
import 'package:mobile/wrappers/permission_handler_wrapper.dart';
import 'package:mobile/wrappers/photo_manager_wrapper.dart';
import 'package:mobile/wrappers/services_wrapper.dart';
import 'package:mobile/wrappers/shared_preferences_wrapper.dart';
import 'package:mobile/wrappers/url_launcher_wrapper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:purchases_flutter/object_wrappers.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sqflite/sqflite.dart';

import 'mocks.mocks.dart';

// TODO: Remove generation - https://github.com/dart-lang/mockito/issues/347

Trip_CatchesPerEntity newInputItemShim(dynamic pickerItem) =>
    Trip_CatchesPerEntity();

@GenerateMocks([AnglerManager])
@GenerateMocks([AppManager])
@GenerateMocks([AppPreferenceManager])
@GenerateMocks([], customMocks: [MockSpec<map.ArgumentCallbacks>()])
@GenerateMocks([AtmosphereFetcher])
@GenerateMocks([BaitCategoryManager])
@GenerateMocks([BaitManager])
@GenerateMocks([BodyOfWaterManager])
@GenerateMocks([CatchManager])
@GenerateMocks([CustomEntityManager])
@GenerateMocks([FishingSpotManager])
@GenerateMocks([ImageManager])
@GenerateMocks([LocalDatabaseManager])
@GenerateMocks([LocationMonitor])
@GenerateMocks([MethodManager])
@GenerateMocks([PreferenceManager])
@GenerateMocks([PropertiesManager])
@GenerateMocks([ReportManager])
@GenerateMocks([SpeciesManager])
@GenerateMocks([SubscriptionManager])
@GenerateMocks([TimeManager])
@GenerateMocks([TripManager])
@GenerateMocks([UserPreferenceManager])
@GenerateMocks([WaterClarityManager])
@GenerateMocks([FilePickerWrapper])
@GenerateMocks([FirebaseAuthWrapper])
@GenerateMocks([FirebaseStorageWrapper])
@GenerateMocks([FirebaseWrapper])
@GenerateMocks([FirestoreWrapper])
@GenerateMocks([], customMocks: [MockSpec<GlobalKey>()])
@GenerateMocks([HttpWrapper])
@GenerateMocks([ImageCompressWrapper])
@GenerateMocks([IoWrapper])
@GenerateMocks([map.MapboxMapController])
@GenerateMocks([PackageInfoWrapper])
@GenerateMocks([PathProviderWrapper])
@GenerateMocks([PermissionHandlerWrapper])
@GenerateMocks([PhotoManagerWrapper])
@GenerateMocks([PurchasesWrapper])
@GenerateMocks([ServicesWrapper])
@GenerateMocks([SharedPreferencesWrapper])
@GenerateMocks([UrlLauncherWrapper])
@GenerateMocks([AssetPathEntity])
@GenerateMocks([Batch])
@GenerateMocks([], customMocks: [MockSpec<CollectionReference>()])
@GenerateMocks([Completer])
@GenerateMocks([DatabaseExecutor])
@GenerateMocks([Directory])
@GenerateMocks([DocumentChange])
@GenerateMocks([], customMocks: [MockSpec<DocumentReference>()])
@GenerateMocks([DocumentSnapshot])
@GenerateMocks([DownloadTask])
@GenerateMocks([EntitlementInfo])
@GenerateMocks([EntitlementInfos])
@GenerateMocks([], customMocks: [MockSpec<EntityListener>()])
@GenerateMocks([FileSystemEntity])
@GenerateMocks([FullMetadata])
@GenerateMocks([LegacyImporter])
@GenerateMocks([LogInResult])
@GenerateMocks([MethodChannel])
@GenerateMocks([NameValidator])
@GenerateMocks([NavigatorObserver])
@GenerateMocks([Offering])
@GenerateMocks([Offerings])
@GenerateMocks([Package])
@GenerateMocks([Product])
@GenerateMocks([PurchaserInfo])
@GenerateMocks([], customMocks: [
  MockSpec<QuantityPickerInputDelegate>(
    fallbackGenerators: {
      #newInputItem: newInputItemShim,
    },
  )
])
@GenerateMocks([QuerySnapshot])
@GenerateMocks([Reference])
@GenerateMocks([Response])
@GenerateMocks([], customMocks: [MockSpec<StreamSubscription>()])
@GenerateMocks([TaskSnapshot])
@GenerateMocks([UploadTask])
@GenerateMocks([User])
@GenerateMocks([UserCredential])
// @GenerateMocks interprets AuthError as a class and tries to call
// AuthError?.value, which throws a compile time error.
class MockAuthManager extends Mock implements AuthManager {
  @override
  String get firestoreDocPath =>
      (super.noSuchMethod(Invocation.getter(#firestoreDocPath), returnValue: "")
          as String);

  @override
  AuthState get state => (super.noSuchMethod(Invocation.getter(#state),
      returnValue: AuthState.unknown) as AuthState);

  @override
  Stream<void> get stream => (super.noSuchMethod(Invocation.getter(#stream),
      returnValue: MockStream<void>()) as Stream<void>);

  @override
  bool get isUserVerified =>
      (super.noSuchMethod(Invocation.getter(#isUserVerified), returnValue: true)
          as bool);

  @override
  Future<void> initialize() =>
      super.noSuchMethod(Invocation.method(#initialize, []),
          returnValue: Future.value(null)) as Future<void>;

  @override
  Future<AuthError?> login(String? email, String? password) =>
      super.noSuchMethod(Invocation.method(#login, [email, password]),
          returnValue: Future.value(null)) as Future<AuthError?>;

  @override
  Future<void> reloadUser() =>
      super.noSuchMethod(Invocation.method(#reloadUser, []),
          returnValue: Future.value(null)) as Future<void>;

  @override
  Future<void> sendResetPasswordEmail(String? email) =>
      super.noSuchMethod(Invocation.method(#sendResetPasswordEmail, [email]),
          returnValue: Future.value(null)) as Future<void>;

  @override
  Future<bool> sendVerificationEmail(int? msBetweenSends) => super.noSuchMethod(
      Invocation.method(#sendVerificationEmail, [msBetweenSends]),
      returnValue: Future.value(false)) as Future<bool>;

  @override
  Future<AuthError?> signUp(String? email, String? password) =>
      super.noSuchMethod(Invocation.method(#signUp, [email, password]),
          returnValue: Future.value(null)) as Future<AuthError?>;
}

// @GenerateMocks can't generate mock because of an internal type used in API.
class MockFile extends Mock implements File {
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
class MockAssetEntity extends AssetEntity {
  final String fileName;
  final DateTime? dateTime;
  final LatLng? latLngAsync;

  int latLngAsyncCalls = 0;

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
  DateTime get createDateTime => dateTime ?? DateTime.now();

  @override
  Future<Uint8List?> get thumbData =>
      Future.value(File("test/resources/$fileName").readAsBytesSync());

  @override
  Future<LatLng> latlngAsync() {
    latLngAsyncCalls++;
    return Future.value(latLngAsync ?? const LatLng(latitude: 0, longitude: 0));
  }

  @override
  Future<File?> get originFile =>
      Future.value(File("test/resources/$fileName"));
}

void main() {}
