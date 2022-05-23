import 'package:collection/collection.dart' show IterableExtension;

/// Returns a sorted version of the given map. If [comparator] is null, the
/// result will be sorted by value, largest to smallest.
Map<T, int> sortedIntMap<T>(Map<T, int> map,
    [int Function(T lhs, T rhs)? comparator]) {
  return sortedMap<T, int>(
      map, comparator ?? ((lhs, rhs) => map[rhs]!.compareTo(map[lhs]!)));
}

/// Returns a sorted version of [map] by the map's keys using the default
/// implementation of [int.compareTo] (smallest to largest).
Map<int, int> sortedMapByIntKey(Map<int, int> map) {
  return sortedIntMap<int>(map, (lhs, rhs) => lhs.compareTo(rhs));
}

Map<T, U> sortedMap<T, U>(
    Map<T, U> map, int Function(T lhs, T rhs) comparator) {
  var sortedKeys = map.keys.toList()..sort(comparator);

  var sortedMap = <T, U>{};
  for (var key in sortedKeys) {
    sortedMap[key] = map[key] as U;
  }

  return sortedMap;
}

void sortIntMap<T>(Map<T, int> map, [int Function(T lhs, T rhs)? comparator]) {
  var newMap = sortedIntMap<T>(map, comparator);
  map.clear();
  map.addAll(newMap);
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

extension Iterables<T> on Iterable<T> {
  bool containsWhere(bool Function(T) comparator) =>
      firstWhereOrNull((e) => comparator(e)) != null;
}
