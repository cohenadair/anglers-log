import 'dart:collection';

/// Returns a sorted version of the given map. If [comparator] is null, the
/// result will be sorted by value, largest to smallest.
Map<T, int> sortedMap<T>(Map<T, int> map,
    [int Function(T lhs, T rhs) comparator])
{
  comparator = comparator ?? (lhs, rhs) => map[rhs].compareTo(map[lhs]);
  var sortedKeys = map.keys.toList()..sort(comparator);

  var sortedMap = LinkedHashMap<T, int>();
  sortedKeys.forEach((key) => sortedMap[key] = map[key]);

  return sortedMap;
}

/// Returns a sub-map of [map], of the first [numberOfElements]. If
/// [numberOfElements] is null, [map] is returned.
Map<T, int> firstElements<T>(Map<T, int> map, {int numberOfElements}) {
  if (numberOfElements == null || numberOfElements > map.length) {
    return map;
  }

  Map<T, int> result = {};
  map.keys
      .toList()
      .sublist(0, numberOfElements)
      .forEach((key) => result[key] = map[key]);

  return result;
}

/// Used to get the value of an enum from an index. Returns null of [index]
/// falls out of bounds of the enum.
T valueOf<T>(List<T> values, int index) {
  if (index == null || index >= values.length) {
    return null;
  }
  return values[index];
}