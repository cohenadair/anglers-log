import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/model/gen/anglers_log.pb.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/finder.dart';
import 'mocks.mocks.dart';
import 'stubbed_managers.dart';

class StubbedMapController {
  final MockMapController value = MockMapController();

  final _symbols = <Symbol>{};

  StubbedMapController(StubbedManagers managers) {
    when(value.animateCamera(any)).thenAnswer((_) => Future.value());
    when(value.moveCamera(any)).thenAnswer((_) => Future.value());
    when(value.addOnSymbolTapped(any)).thenAnswer((_) {});
    when(value.setAllowSymbolOverlap(any)).thenAnswer((_) => Future.value());
    when(value.setTelemetryEnabled(any)).thenAnswer((_) => Future.value());
    when(value.isTelemetryEnabled()).thenAnswer((_) => Future.value(false));

    when(value.clearSymbols()).thenAnswer((_) {
      _symbols.clear();
      return Future.value();
    });

    when(value.addSymbols(any)).thenAnswer((invocation) {
      var symbols = invocation.positionalArguments[0] as List<Symbol>;
      _symbols.addAll(
        // Real map SDK is responsible for setting the Symbol's ID, so we set
        // it here.
        symbols.map<Symbol>((s) => s.deepCopy()..id = randomId().uuid),
      );
      return Future.value(_symbols);
    });

    when(value.addSymbol(any)).thenAnswer((invocation) async {
      return (await value.addSymbols([
        invocation.positionalArguments[0],
      ])).first;
    });

    when(value.removeSymbol(any)).thenAnswer((invocation) {
      _symbols.remove(invocation.positionalArguments[0]);
      return Future.value();
    });

    when(value.updateSymbol(any)).thenAnswer((invocation) {
      final updatedSymbol = invocation.positionalArguments[0] as Symbol;
      _symbols.removeWhere((s) => s.id == updatedSymbol.id);
      _symbols.add(updatedSymbol);
      return Future.value(updatedSymbol);
    });

    when(value.symbols).thenAnswer((_) => List.unmodifiable(_symbols));
    when(value.fishingSpotSymbols).thenAnswer(
      (_) => List.unmodifiable(_symbols.where((s) => s.fishingSpot != null)),
    );

    when(
      managers.mapControllerFactory.createMapbox(
        any,
        myLocationEnabled: anyNamed("myLocationEnabled"),
      ),
    ).thenAnswer((_) => Future.value(value));
  }

  /// MapboxMap callbacks aren't called in widget tests, so we manually invoke
  /// them when needed.
  Future<void> finishLoading(WidgetTester tester) async {
    findFirst<MapWidget>(tester).onMapCreated?.call(MockMapboxMap());
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  int get symbolCount => _symbols.length;

  void clearSymbols() => _symbols.clear();
}
