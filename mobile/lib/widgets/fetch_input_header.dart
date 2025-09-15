import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:adair_flutter_lib/utils/snack_bar.dart';
import 'package:adair_flutter_lib/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

import '../fishing_spot_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../pages/anglers_log_pro_page.dart';
import '../res/style.dart';
import '../utils/string_utils.dart';
import 'input_controller.dart';
import 'list_item.dart';
import 'widget.dart';

class FetchInputResult<T> {
  final T? data;
  final String? errorMessage;
  final bool notifyOnError;

  FetchInputResult({this.data, this.errorMessage}) : notifyOnError = true;

  /// Use, if for some reason, a [FetchInputResult] needs to be returned, but
  /// the user shouldn't be notified (because they may have already been
  /// notified another way, such as when requesting location permissions).
  FetchInputResult.noNotify()
    : data = null,
      errorMessage = null,
      notifyOnError = false;
}

class FetchInputHeader<T> extends StatefulWidget {
  final FishingSpot? fishingSpot;
  final String defaultErrorMessage;
  final TZDateTime dateTime;
  final Future<FetchInputResult<T?>> Function() onFetch;
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
          title: Text(location, style: stylePrimary(context)),
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
    if (_isLoading) {
      return;
    }

    if (SubscriptionManager.get.isFree) {
      present(context, const AnglersLogProPage());
      return;
    }

    setState(() => _isLoading = true);

    var result = await widget.onFetch();
    if (!mounted) {
      return;
    }

    if (result.data == null) {
      if (result.notifyOnError) {
        showErrorSnackBar(
          context,
          result.errorMessage ?? widget.defaultErrorMessage,
        );
      }
    } else {
      widget.onFetchSuccess(result.data as T);
    }

    setState(() => _isLoading = false);
  }
}
