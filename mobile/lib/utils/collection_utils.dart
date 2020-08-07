import 'dart:collection';

/// Returns a largest-to-smallest, sorted-by-value version of [map].
Map<T, int> sortedMap<T>(Map<T, int> map) {
  var sortedKeys = map.keys.toList()
    ..sort((lhs, rhs) => map[rhs].compareTo(map[lhs]));

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