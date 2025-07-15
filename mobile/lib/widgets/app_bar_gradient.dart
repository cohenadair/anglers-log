import 'package:flutter/material.dart';

/// A gradient background meant to be used behind or in place of an [AppBar]
/// so action buttons are always visible, no matter what is rendered beneath.
class AppBarGradient extends StatelessWidget {
  static const double _defaultHeight = 125;
  static const double _expandedStartAlpha = 0.7;
  static const double _expandedEndAlpha = 0.0;

  final double height;

  const AppBarGradient({this.height = _defaultHeight});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: _expandedStartAlpha),
              Colors.white.withValues(alpha: _expandedEndAlpha),
            ],
          ),
        ),
        width: MediaQuery.of(context).size.width,
        height: height,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
