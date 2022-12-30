import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mobile/res/dimen.dart';

import '../widgets/button.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/floating_container.dart';
import '../widgets/mapbox_attribution.dart';
import '../widgets/widget.dart';

class DetailsMapPage extends StatelessWidget {
  final MapboxMapController? controller;
  final DefaultMapboxMap map;
  final Widget details;
  final List<Widget> children;
  final bool isPresented;

  const DetailsMapPage({
    required this.controller,
    required this.map,
    required this.details,
    this.children = const [],
    this.isPresented = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          map,
          _buildBackButton(),
          _buildDetails(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: isPresented
            ? const FloatingButton.close()
            : const FloatingButton.back(),
      ),
    );
  }

  Widget _buildDetails() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: insetsDefault,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MapboxAttribution(mapController: controller),
              const VerticalSpace(paddingSmall),
              FloatingContainer(
                padding: insetsDefault,
                child: details,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
