import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

import '../fishing_spot_manager.dart';
import '../i18n/strings.dart';
import '../model/gen/anglerslog.pb.dart';
import '../pages/pro_page.dart';
import '../res/style.dart';
import '../subscription_manager.dart';
import '../utils/date_time_utils.dart';
import '../utils/page_utils.dart';
import '../utils/snackbar_utils.dart';
import '../utils/widget_utils.dart';
import 'input_controller.dart';
import 'list_item.dart';
import 'widget.dart';

class FetchResult<T> {
  final T? data;
  final String? errorMessage;

  FetchResult({
    this.data,
    this.errorMessage,
  });
}

class FetchInputHeader<T> extends StatefulWidget {
  final FishingSpot? fishingSpot;
  final String defaultErrorMessage;
  final TZDateTime dateTime;
  final Future<FetchResult<T?>> Function() onFetch;
  final void Function(T) onFetchSuccess;
  final InputController<T> controller;

  const FetchInputHeader({
    this.fishingSpot,
    required this.defaultErrorMessage,
    required this.dateTime,
    required this.onFetch,
    required this.onFetchSuccess,
    required this.controller,
  });

  @override
  State<FetchInputHeader<T>> createState() => _FetchInputHeaderState<T>();
}

class _FetchInputHeaderState<T> extends State<FetchInputHeader<T>> {
  bool _isLoading = false;

  FishingSpotManager get _fishingSpotManager => FishingSpotManager.of(context);

  SubscriptionManager get _subscriptionManager =>
      SubscriptionManager.of(context);

  @override
  Widget build(BuildContext context) {
    var location = Strings.of(context).inputCurrentLocation;
    if (widget.fishingSpot != null) {
      location = _fishingSpotManager.displayName(
        context,
        widget.fishingSpot!,
        useLatLngFallback: true,
        includeLatLngLabels: true,
        includeBodyOfWater: true,
      );
    }

    return Column(
      children: [
        ListItem(
          title: Text(
            location,
            style: stylePrimary(context),
          ),
          subtitle: Text(
            formatDateTime(context, widget.dateTime),
            style: stylePrimary(context),
          ),
          trailing: _buildFetchButton(),
        ),
        const MinDivider(),
        NoneFormHeader(controller: widget.controller),
      ],
    );
  }

  Widget _buildFetchButton() {
    return ElevatedButton(
      onPressed: _fetch,
      child: _isLoading
          ? const Loading(isCentered: false, isAppBar: true)
          : Text(Strings.of(context).inputFetch.toUpperCase()),
    );
  }

  Future<void> _fetch() async {
    if (_subscriptionManager.isFree) {
      present(context, const ProPage());
      return;
    }

    setState(() => _isLoading = true);

    var result = await widget.onFetch();
    safeUseContext(this, () {
      if (result.data == null) {
        showErrorSnackBar(
            context, result.errorMessage ?? widget.defaultErrorMessage);
      } else {
        widget.onFetchSuccess(result.data as T);
      }
    });

    setState(() => _isLoading = false);
  }
}
