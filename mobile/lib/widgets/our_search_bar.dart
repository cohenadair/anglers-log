import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/res/theme.dart';
import 'package:quiver/strings.dart';

import '../res/dimen.dart';
import '../widgets/widget.dart';
import 'floating_container.dart';

class OurSearchBar extends StatefulWidget {
  static const height = 40.0;

  final String? text;
  final String? hint;
  final EdgeInsets? margin;

  /// A widget to show before the search text. Usually an [Icon].
  /// Defaults to [Icons.search].
  final Widget? leading;

  /// The padding between the leading widget and search text. This is useful
  /// for horizontally aligning text with widgets in a list, for example.
  /// Defaults to [paddingDefault].
  final double? leadingPadding;

  /// A widget to show after the text. Usually an [IconButton]. When
  /// input is allowed, defaults to a close button to clear the text.
  final Widget? trailing;

  /// When true, a shadow is rendered beneath the [OurSearchBar]. Defaults to
  /// true.
  final bool elevated;

  final SearchBarDelegate delegate;

  const OurSearchBar({
    this.text,
    this.hint,
    this.margin,
    this.leading,
    this.leadingPadding,
    this.trailing,
    this.elevated = true,
    required this.delegate,
  });

  @override
  OurSearchBarState createState() => OurSearchBarState();
}

class OurSearchBarState extends State<OurSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late VoidCallback _onFocusChanged;

  bool get _isInput => widget.delegate.searchBarType == SearchBarType.input;

  bool get focused => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();

    _updateControllerText();

    _onFocusChanged = () => setState(() {});
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(OurSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset controller text and cursor position in case the parent changed
    // the input text.
    _updateControllerText();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var leading = widget.leading ??
        Padding(
          padding: EdgeInsets.only(
            left: paddingDefault,
            right: widget.leadingPadding ?? paddingDefault,
          ),
          child: Icon(Icons.search, color: context.colorIconFloatingButton),
        );

    Widget trailing = const Empty();
    if (widget.trailing != null) {
      trailing = widget.trailing!;
    } else if (_isInput) {
      trailing = AnimatedVisibility(
        visible: focused || isNotEmpty(_controller.text),
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              // Only notify delegate if text changes.
              if (isNotEmpty(_controller.text)) {
                _controller.text = "";
                widget.delegate.onTextChanged(_controller.text);
              }
            });
          },
        ),
      );
    }

    return SafeArea(
      child: FloatingContainer(
        height: OurSearchBar.height,
        margin: widget.margin,
        onTap: widget.delegate.onTap(),
        child: Row(
          children: <Widget>[
            leading,
            Expanded(
              // Use IgnorePointer instead of CupertinoTextField.enabled so
              // the background doesn't change when disabled.
              child: IgnorePointer(
                ignoring: !_isInput,
                child: CupertinoTextField(
                  padding: insetsZero,
                  decoration: null,
                  onChanged: widget.delegate.onTextChanged,
                  placeholder: widget.hint,
                  placeholderStyle: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).disabledColor),
                  style: TextStyle(
                    color: context.colorAppBarContent,
                  ),
                  controller: _controller,
                  focusNode: _focusNode,
                  cursorColor: context.colorDefault,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _updateControllerText() {
    var text = widget.text ?? "";
    _controller.value = _controller.value.copyWith(
      text: text,
      // Ensures cursor is at the end of the text. By default, setting
      // TextEditingController.text resets cursor to beginning of text.
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

enum SearchBarType { button, input }

/// Defines the behavior of a [OurSearchBar].
abstract class SearchBarDelegate {
  /// Tells the [OurSearchBar] to act like a button and is invoked when the
  /// [OurSearchBar] is tapped. When a non-null value is returned, the [OurSearchBar]
  /// text input is disabled.
  ///
  /// Return a non-null value to use the Flutter [showSearch] function.
  VoidCallback? onTap();

  /// Called when the text input changes, or the input is cleared. This only
  /// applies when [searchBarType] is equal to [SearchBarType.input].
  ///
  /// See [CupertinoTextField.onChanged].
  void onTextChanged(String text);

  SearchBarType get searchBarType;
}

class ButtonSearchBarDelegate extends SearchBarDelegate {
  final VoidCallback onPressed;

  ButtonSearchBarDelegate(this.onPressed);

  @override
  VoidCallback onTap() => onPressed;

  @override
  void onTextChanged(String text) {
    // Do nothing.
  }

  @override
  SearchBarType get searchBarType => SearchBarType.button;
}

class InputSearchBarDelegate extends SearchBarDelegate {
  final Function(String) onChanged;

  InputSearchBarDelegate(this.onChanged);

  @override
  VoidCallback? onTap() => null;

  @override
  void onTextChanged(String text) => onChanged.call(text);

  @override
  SearchBarType get searchBarType => SearchBarType.input;
}
