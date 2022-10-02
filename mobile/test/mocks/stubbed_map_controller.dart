import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mockito/mockito.dart';

import '../test_utils.dart';
import 'mocks.mocks.dart';

class StubbedMapController {
  final MockMapboxMapController value = MockMapboxMapController();

  final _symbols = <Symbol>[];

  StubbedMapController() {
    when(value.animateCamera(any)).thenAnswer((_) => Future.value(true));
    when(value.moveCamera(any)).thenAnswer((_) => Future.value(true));
    when(value.onSymbolTapped).thenReturn(ArgumentCallbacks<Symbol>());
    when(value.setSymbolIconAllowOverlap(any))
        .thenAnswer((_) => Future.value());
    when(value.setTelemetryEnabled(any)).thenAnswer((_) => Future.value());
    when(value.getTelemetryEnabled()).thenAnswer((_) => Future.value(false));
    when(value.toLatLng(any))
        .thenAnswer((_) => Future.value(const LatLng(0, 0)));

    when(value.clearSymbols()).thenAnswer((_) {
      _symbols.clear();
      return Future.value();
    });

    when(value.addSymbols(any, any)).thenAnswer((invocation) {
      var options = invocation.positionalArguments[0];
      for (var i = 0; i < options.length; i++) {
        _symbols.add(
            _createSymbol(options[i], invocation.positionalArguments[1][i]));
      }
      return Future.value(_symbols);
    });

    when(value.addSymbol(any, any)).thenAnswer((invocation) {
      var symbol = _createSymbol(
        invocation.positionalArguments[0],
        invocation.positionalArguments[1],
      );
      _symbols.add(symbol);
      return Future.value(symbol);
    });

    when(value.removeSymbol(any)).thenAnswer((invocation) {
      _symbols.remove(invocation.positionalArguments[0]);
      return Future.value();
    });

    when(value.updateSymbol(any, any)).thenAnswer((invocation) {
      var currentSymbol = invocation.positionalArguments[0] as Symbol;
      currentSymbol.options =
          currentSymbol.options.copyWith(invocation.positionalArguments[1]);
      return Future.value();
    });

    when(value.symbols).thenAnswer((_) => _symbols.toSet());
  }

  /// MapboxMap callbacks aren't called in widget tests, so we manually invoke
  /// them when needed.
  Future<void> finishLoading(WidgetTester tester) async {
    var mapboxMap = findFirst<MapboxMap>(tester);
    mapboxMap.onMapCreated?.call(value);
    mapboxMap.onStyleLoadedCallback?.call();
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
  }

  int get symbolCount => _symbols.length;

  void clearSymbols() => _symbols.clear();

  Symbol _createSymbol(SymbolOptions options, Map<dynamic, dynamic>? data) =>
      Symbol(randomId().uuid, options, data);
}
