import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/utils/map_utils.dart';

import '../map/map_controller.dart';
import '../widgets/button.dart';
import '../widgets/default_mapbox_map.dart';
import '../widgets/floating_container.dart';
import '../widgets/map_attribution.dart';

class DetailsMapPage extends StatefulWidget {
  final MapController? controller;
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
  State<DetailsMapPage> createState() => _DetailsMapPageState();
}

class _DetailsMapPageState extends State<DetailsMapPage> {
  final _detailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateAttributionMargin(),
    );
  }

  @override
  void didUpdateWidget(DetailsMapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateAttributionMargin(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.map,
          _buildBackButton(),
          _buildDetails(),
          ...widget.children,
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: widget.isPresented
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
              MapboxAttribution(mapController: widget.controller),
              Container(height: paddingSmall),
              FloatingContainer(
                key: _detailsKey,
                padding: insetsDefault,
                child: widget.details,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateAttributionMargin() =>
      updateMapAttributionMargin(_detailsKey, widget.controller);
}
