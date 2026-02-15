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

  final _symbols = <Symbol>[];

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
      var symbols = invocation.positionalArguments[0];
      _symbols.addAll(symbols.map((s) => _createSymbol(s)));
      return Future.value(_symbols);
    });

    when(value.addSymbol(any)).thenAnswer((invocation) async {
      final symbol = invocation.positionalArguments[0] as Symbol;
      return (await value.addSymbols([symbol])).first;
    });

    when(value.removeSymbol(any)).thenAnswer((invocation) {
      _symbols.remove(invocation.positionalArguments[0]);
      return Future.value();
    });

    when(value.updateSymbol(any)).thenAnswer((invocation) {
      final updatedSymbol = invocation.positionalArguments[0] as Symbol;
      final index = _symbols.indexWhere((s) => s.id == updatedSymbol.id);
      _symbols.replaceRange(index, index, [updatedSymbol]);
      return Future.value(updatedSymbol);
    });

    when(value.symbols).thenAnswer((_) => List.unmodifiable(_symbols));

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

  Symbol _createSymbol(Symbol symbol) =>
      symbol.deepCopy()..id = randomId().uuid;
}
