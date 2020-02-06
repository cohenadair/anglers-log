import 'package:flutter/material.dart';

/// A [DropdownButtonFormField] wrapper. To disable, set either [options] or
/// [onChanged] to `null`.
class DropdownInput<T> extends StatelessWidget {
  final List<T> options;
  final Function(T) onChanged;
  final T value;

  /// Return a [Widget] rendered as the option for the given [T] value.
  final Widget Function(T value) buildOption;

  DropdownInput({
    @required this.options,
    @required this.onChanged,
    @required this.buildOption,
    this.value,
  }) : assert(options != null && options.length > 0),
       assert(onChanged != null),
       assert(buildOption != null);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      items: options.map((T option) {
        return DropdownMenuItem(
          child: buildOption(option),
          value: option,
        );
      }).toList(),
      onChanged: onChanged,
      value: value,
    );
  }
}