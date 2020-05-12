import 'package:flutter/material.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/widgets/text.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

class SearchBar extends StatelessWidget {
  final String hint;
  final String text;
  final Widget leading;
  final Widget trailing;

  /// The padding between the leading widget and search text. This is useful
  /// for horizontally aligning text with widgets in a list, for example.
  /// Defaults to [paddingDefault].
  final double leadingPadding;

  final EdgeInsets margin;
  final VoidCallback onTap;
  final bool elevated;

  SearchBar({
    this.hint,
    this.text,
    this.leading,
    this.leadingPadding,
    this.trailing,
    this.margin,
    this.onTap,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget title;
    if (isEmpty(text)) {
      title = SecondaryLabelText(hint ?? "");
    } else {
      title = LabelText(text);
    }

    Widget lead;
    if (leading != null) {
      lead = leading;
    } else {
      lead = Padding(
        padding: EdgeInsets.only(
          left: paddingDefault,
          right: leadingPadding ?? paddingDefault,
        ),
        child: leading ?? Icon(Icons.search, color: Colors.black),
      );
    }

    return Container(
      margin: margin,
      decoration: FloatingBoxDecoration.rectangle(elevated: elevated),
      // Wrap InkWell in a Material widget so the fill animation is shown
      // on top of the parent Container widget.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    lead,
                    title,
                  ],
                ),
              ),
              trailing ?? Empty(),
            ],
          ),
        ),
      ),
    );
  }
}