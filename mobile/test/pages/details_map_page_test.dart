import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/map/map_controller.dart';
import 'package:mobile/pages/details_map_page.dart';
import 'package:mobile/utils/map_utils.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/default_mapbox_map.dart';
import 'package:mockito/mockito.dart';

import '../../../../adair-flutter-lib/test/test_utils/testable.dart';
import '../mocks/mocks.mocks.dart';
import '../mocks/stubbed_managers.dart';

void main() {
  late StubbedManagers managers;

  setUp(() async {
    managers = await StubbedManagers.create();
    when(managers.userPreferenceManager.mapType).thenReturn(MapType.light.id);
    when(managers.propertiesManager.mapboxApiKey).thenReturn("");
    when(managers.lib.ioWrapper.isAndroid).thenReturn(false);
  });

  testWidgets("Shows close button", (tester) async {
    await pumpContext(
      tester,
      (_) => DetailsMapPage(
        controller: null,
        map: DefaultMapboxMap(startPosition: LatLngs.zero),
        details: const SizedBox(),
        isPresented: true,
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets("Shows back button", (tester) async {
    await pumpContext(
      tester,
      (_) => Theme(
        data: ThemeData(platform: TargetPlatform.android),
        child: DetailsMapPage(
          controller: null,
          map: DefaultMapboxMap(startPosition: LatLngs.zero),
          details: const SizedBox(),
          isPresented: false,
        ),
      ),
    );
    // Wait for map future to finish.
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets("initState calls updateLogoAndAttributionMarginBottom", (
    tester,
  ) async {
    final mockController = MockMapController();
    when(
      mockController.updateLogoAndAttributionMarginBottom(any),
    ).thenAnswer((_) async {});

    await pumpContext(
      tester,
      (_) => DetailsMapPage(
        controller: mockController,
        map: DefaultMapboxMap(startPosition: LatLngs.zero),
        details: const SizedBox(),
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    verify(mockController.updateLogoAndAttributionMarginBottom(any)).called(1);
  });

  testWidgets(
    "didUpdateWidget calls updateLogoAndAttributionMarginBottom when controller changes",
    (tester) async {
      final mockController1 = MockMapController();
      when(
        mockController1.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});
      final mockController2 = MockMapController();
      when(
        mockController2.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      late StateSetter stateSetter;
      MapController? currentController = mockController1;

      await pumpContext(
        tester,
        (_) => StatefulBuilder(
          builder: (context, setState) {
            stateSetter = setState;
            return DetailsMapPage(
              controller: currentController,
              map: DefaultMapboxMap(startPosition: LatLngs.zero),
              details: const SizedBox(),
            );
          },
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      clearInteractions(mockController1);

      stateSetter(() => currentController = mockController2);
      await tester.pumpAndSettle();

      verify(
        mockController2.updateLogoAndAttributionMarginBottom(any),
      ).called(1);
      verifyNever(mockController1.updateLogoAndAttributionMarginBottom(any));
    },
  );

  testWidgets(
    "didUpdateWidget does not call updateLogoAndAttributionMarginBottom when controller is unchanged",
    (tester) async {
      final mockController = MockMapController();
      when(
        mockController.updateLogoAndAttributionMarginBottom(any),
      ).thenAnswer((_) async {});

      late StateSetter stateSetter;

      await pumpContext(
        tester,
        (_) => StatefulBuilder(
          builder: (context, setState) {
            stateSetter = setState;
            return DetailsMapPage(
              controller: mockController,
              map: DefaultMapboxMap(startPosition: LatLngs.zero),
              details: const SizedBox(),
            );
          },
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      clearInteractions(mockController);

      stateSetter(() {});
      await tester.pumpAndSettle();

      verifyNever(mockController.updateLogoAndAttributionMarginBottom(any));
    },
  );
}
