import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/tile.dart';
import 'package:mobile/widgets/widget.dart';

import '../test_utils.dart';

void main() {
  testWidgets("Tile title is empty", (tester) async {
    await pumpContext(
      tester,
      (_) => Tile(TileItem(title: "")),
    );
    expect(find.byType(TitleLabel), findsNothing);
  });

  testWidgets("Tile title is not empty", (tester) async {
    await pumpContext(
      tester,
      (_) => Tile(TileItem(title: "Title")),
    );
    expect(find.textStyle("Title", styleTitle1), findsOneWidget);
  });

  testWidgets("Tile subtitle is empty", (tester) async {
    await pumpContext(
      tester,
      (_) => Tile(TileItem(subtitle: "")),
    );
    expect(find.byType(TitleLabel), findsNothing);
  });

  testWidgets("Tile subtitle is not empty", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => Tile(TileItem(subtitle: "Subtitle")),
    );
    expect(find.textStyle("Subtitle", styleTitle2(context)), findsOneWidget);
  });

  testWidgets("Tile subtitle2 is empty", (tester) async {
    await pumpContext(
      tester,
      (_) => Tile(TileItem(subtitle2: "")),
    );
    expect(find.byType(Text), findsNothing);
  });

  testWidgets("Tile subtitle2 is not empty", (tester) async {
    var context = await pumpContext(
      tester,
      (_) => Tile(TileItem(subtitle2: "Subtitle2")),
    );
    expect(find.primaryText(context, text: "Subtitle2"), findsOneWidget);
  });

  testWidgets("TileRow single item", (tester) async {
    await pumpContext(
      tester,
      (_) => TileRow(items: [TileItem(subtitle2: "Subtitle2")]),
    );
    expect(find.byType(HorizontalSpace), findsNothing);
    expect(find.text("Subtitle2"), findsOneWidget);
  });

  testWidgets("TileRow multiple items", (tester) async {
    await pumpContext(
      tester,
      (_) => TileRow(items: [
        TileItem(subtitle2: "Subtitle2 1"),
        TileItem(subtitle2: "Subtitle2 2"),
        TileItem(subtitle2: "Subtitle2 3"),
      ]),
    );
    expect(find.byType(HorizontalSpace), findsNWidgets(2));
    expect(find.text("Subtitle2 1"), findsOneWidget);
    expect(find.text("Subtitle2 2"), findsOneWidget);
    expect(find.text("Subtitle2 2"), findsOneWidget);
  });

  testWidgets("TileRow custom padding", (tester) async {
    await pumpContext(
      tester,
      (_) => TileRow(
        padding: insetsDefault,
        items: [TileItem(subtitle2: "Subtitle2")],
      ),
    );
    expect(findFirst<Container>(tester).padding, insetsDefault);
  });

  testWidgets("TileRow default padding", (tester) async {
    await pumpContext(
      tester,
      (_) => TileRow(
        items: [TileItem(subtitle2: "Subtitle2")],
      ),
    );
    expect(findFirst<Container>(tester).padding, insetsZero);
  });

  testWidgets("TileItem ==", (tester) async {
    expect(TileItem(title: "1"), TileItem(title: "1"));
    expect(TileItem(subtitle: "1"), TileItem(subtitle: "1"));
    expect(TileItem(subtitle2: "1"), TileItem(subtitle2: "1"));
  });
}
