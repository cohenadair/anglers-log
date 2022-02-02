import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/utils/animated_list_model.dart';
import 'package:mobile/utils/protobuf_utils.dart';
import 'package:mobile/widgets/input_controller.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mocks.mocks.dart';

void main() {
  late MockGlobalKey<AnimatedListState> key;

  setUp(() {
    key = MockGlobalKey<AnimatedListState>();
    when(key.currentState).thenReturn(null);
  });

  test("initialItems is empty", () {
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: ListInputController<Species>(),
      removedItemBuilder: (_, __, ___) => const Empty(),
    );
    expect(model.items, isNotNull);
    expect(model.isEmpty, isTrue);
  });

  test("initialItems is null", () {
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: ListInputController<Species>(),
      initialItems: null,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );
    expect(model.items, isNotNull);
    expect(model.isEmpty, isTrue);
  });

  test("Assertion thrown when state is invalid type", () {
    var badKey = MockGlobalKey<__TestStatefulWidgetState>();
    when(badKey.currentState).thenReturn(__TestStatefulWidgetState());

    var model = AnimatedListModel<Species, State<StatefulWidget>>(
      listKey: badKey,
      controller: ListInputController<Species>(),
      initialItems: null,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    expect(() => model.insert(0, Species()), throwsAssertionError);
  });

  test("Inserting", () {
    var controller = ListInputController<Species>();
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: controller,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    model.insert(0, Species());
    expect(model.isNotEmpty, isTrue);
    expect(model.length, 1);
    expect(controller.hasValue, isTrue);
    expect(controller.value.length, 1);
  });

  test("Removing", () {
    var controller = ListInputController<Species>();
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: controller,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    model.insert(0, Species());
    model.insert(0, Species());
    expect(model.length, 2);
    expect(controller.value.length, 2);

    // Out of bounds.
    expect(model.removeAt(-1), isNull);
    expect(model.removeAt(3), isNull);
    expect(controller.value.length, 2);

    // Successful remove.
    expect(model.removeAt(0), isNotNull);
    expect(model.removeAt(0), isNotNull);
    expect(model.isEmpty, isTrue);
    expect(controller.value.isEmpty, isTrue);
  });

  test("Replacing", () {
    var controller = ListInputController<Species>();
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: controller,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    var pike = Species(name: "Pike");
    var bass = Species(name: "Bass");
    model.insert(0, pike);
    model.insert(0, bass);
    expect(model.length, 2);
    expect(model[0].name, "Bass");
    expect(model[1].name, "Pike");
    expect(controller.value.length, 2);
    expect(controller.value[0].name, "Bass");
    expect(controller.value[1].name, "Pike");

    model.replace(0, Species(name: "Salmon"));
    expect(model[0].name, "Salmon");
    expect(model[1].name, "Pike");
    expect(controller.value[0].name, "Salmon");
    expect(controller.value[1].name, "Pike");
  });

  test("Resetting items", () {
    var bassId = randomId();
    var perchId = randomId();

    var oldItems = <Species>[
      Species(id: bassId, name: "Bass"),
      Species(id: randomId(), name: "Pike"),
      Species(id: randomId(), name: "Walleye"),
      Species(id: perchId, name: "Perch"),
    ];

    var controller = ListInputController<Species>();
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: controller,
      initialItems: oldItems,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    var newItems = <Species>[
      Species(id: bassId, name: "Bass"),
      Species(id: randomId(), name: "Bluegill"),
      Species(id: randomId(), name: "Catfish"),
      Species(id: perchId, name: "Perch"),
      Species(id: randomId(), name: "Carp"),
    ];
    model.resetItems(newItems);

    expect(model.length, 5);
    expect(model[0].name, "Bass");
    expect(model[1].name, "Bluegill");
    expect(model[2].name, "Catfish");
    expect(model[3].name, "Perch");
    expect(model[4].name, "Carp");
    expect(controller.value.length, 5);
    expect(controller.value[0].name, "Bass");
    expect(controller.value[1].name, "Bluegill");
    expect(controller.value[2].name, "Catfish");
    expect(controller.value[3].name, "Perch");
    expect(controller.value[4].name, "Carp");
  });

  test("Updating order of items", () {
    var bassId = randomId();
    var perchId = randomId();
    var pikeId = randomId();
    var walleyeId = randomId();

    var oldItems = <Species>[
      Species(id: bassId, name: "Bass"),
      Species(id: pikeId, name: "Pike"),
      Species(id: walleyeId, name: "Walleye"),
      Species(id: perchId, name: "Perch"),
    ];

    var controller = ListInputController<Species>();
    var model = AnimatedListModel<Species, AnimatedListState>(
      listKey: key,
      controller: controller,
      initialItems: oldItems,
      removedItemBuilder: (_, __, ___) => const Empty(),
    );

    var newItems = <Species>[
      Species(id: perchId, name: "Perch"),
      Species(id: pikeId, name: "Pike"),
      Species(id: bassId, name: "Bass"),
      Species(id: walleyeId, name: "Walleye"),
    ];
    model.resetItems(newItems);

    expect(model.length, 4);
    expect(model[0].name, "Perch");
    expect(model[1].name, "Pike");
    expect(model[2].name, "Bass");
    expect(model[3].name, "Walleye");
    expect(controller.value.length, 4);
    expect(controller.value[0].name, "Perch");
    expect(controller.value[1].name, "Pike");
    expect(controller.value[2].name, "Bass");
    expect(controller.value[3].name, "Walleye");
  });
}

class _TestStatefulWidget extends StatefulWidget {
  @override
  __TestStatefulWidgetState createState() => __TestStatefulWidgetState();
}

class __TestStatefulWidgetState extends State<_TestStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return const Empty();
  }
}
