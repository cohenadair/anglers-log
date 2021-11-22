import 'package:collection/collection.dart' show IterableExtension;

/// Returns a sorted version of the given map. If [comparator] is null, the
/// result will be sorted by value, largest to smallest.
Map<T, int> sortedMap<T>(Map<T, int> map,
    [int Function(T lhs, T rhs)? comparator]) {
  comparator = comparator ?? ((lhs, rhs) => map[rhs]!.compareTo(map[lhs]!));
  var sortedKeys = map.keys.toList()..sort(comparator);

  var sortedMap = <T, int>{};
  for (var key in sortedKeys) {
    sortedMap[key] = map[key]!;
  }

  return sortedMap;
}

/// Returns a sub-map of [map], of the first [numberOfElements]. If
/// [numberOfElements] is null, [map] is returned.
Map<T, int> firstElements<T>(Map<T, int> map, {int? numberOfElements}) {
  if (numberOfElements == null || numberOfElements > map.length) {
    return map;
  }

  var result = <T, int>{};
  map.keys
      .toList()
      .sublist(0, numberOfElements)
      .forEach((key) => result[key] = map[key]!);

  return result;
}

/// Used to get the value of an enum from an index. Returns null of [index]
/// falls out of bounds of the enum.
T? valueOf<T>(List<T> values, int index) {
  if (index >= values.length) {
    return null;
  }
  return values[index];
}

Set<T> singleSet<T>(T? item) => item == null ? {} : {item};

extension Iterables on Iterable {
  bool containsWhere<T>(bool Function(T) comparator) =>
      firstWhereOrNull((e) => comparator(e as T)) != null;
}
