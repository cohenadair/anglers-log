import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/widget.dart';

import '../i18n/strings.dart';
import '../utils/number_utils.dart';
import '../utils/protobuf_utils.dart';
import '../widgets/filled_row.dart';
import 'feedback_page.dart';

class PollsPage extends StatefulWidget {
  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  late Future<void> _fetchPollsFuture;

  PollManager get _pollManager => PollManager.of(context);

  @override
  void initState() {
    super.initState();
    _fetchPollsFuture = _pollManager.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollPage(
      appBar: AppBar(
        title: Text(Strings.of(context).pollsPageTitle),
      ),
      padding: insetsDefault,
      children: [
        FutureBuilder<void>(
          future: _fetchPollsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Loading();
            }

            if (_pollManager.freePoll != null || _pollManager.proPoll != null) {
              return _buildPolls();
            } else {
              return _buildPlaceholder();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPolls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntroText(),
        const VerticalSpace(paddingDefault),
        _buildFreePoll(),
        const VerticalSpace(paddingDefault),
        _buildProPoll(),
        const VerticalSpace(paddingDefault),
        _buildThankYou(),
        const VerticalSpace(paddingDefault),
      ],
    );
  }

  Widget _buildIntroText() {
    return Text(
      Strings.of(context).pollsPageDescription,
      style: stylePrimary(context),
    );
  }

  Widget _buildFreePoll() {
    return _Poll(
      title: Strings.of(context).pollsPageNextFreeFeature,
      optionValues: _pollManager.freePoll?.optionValues ?? {},
      canVote: _pollManager.canVoteFree,
      onVote: () {
        // TODO
      },
    );
  }

  Widget _buildProPoll() {
    return _Poll(
      title: Strings.of(context).pollsPageNextProFeature,
      optionValues: _pollManager.proPoll?.optionValues ?? {},
      canVote: _pollManager.canVotePro,
      onVote: () {
        // TODO
      },
    );
  }

  Widget _buildThankYou() {
    if (!_pollManager.canVoteFree && !_pollManager.canVotePro) {
      return Center(
        child: Text(
          Strings.of(context).pollsPageThankYou,
          style: styleSuccess(context),
        ),
      );
    }
    return const Empty();
  }

  Widget _buildPlaceholder() {
    return Column(
      children: [
        EmptyListPlaceholder.static(
          title: Strings.of(context).pollsPageNoPollsTitle,
          description: Strings.of(context).pollsPageNoPollsDescription,
          icon: Icons.poll,
        ),
        Button(
          text: Strings.of(context).pollsPageSendFeedback,
          onPressed: () => present(context, const FeedbackPage()),
        ),
      ],
    );
  }
}

class _Poll extends StatefulWidget {
  final String title;
  final Map<String, int> optionValues;
  final bool canVote;
  final VoidCallback? onVote;

  const _Poll({
    required this.title,
    required this.optionValues,
    required this.canVote,
    this.onVote,
  });

  @override
  State<_Poll> createState() => _PollState();
}

class _PollState extends State<_Poll> {
  static const _rowHeight = 35.0;
  static const _rowMaxValue = 100.0; // 100%.

  var _canVote = false;

  @override
  void initState() {
    super.initState();
    _canVote = widget.canVote;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: styleListHeading(context)),
        const VerticalSpace(paddingDefault),
        ...widget.optionValues.keys.map((option) {
          var total = widget.optionValues.values.toList().sum;
          var value =
              percent(widget.optionValues[option] ?? 0, total == 0 ? 1 : total);

          return Padding(
            padding: insetsBottomSmall,
            child: FilledRow(
              height: _rowHeight,
              maxValue: _rowMaxValue,
              value: value,
              showValue: !_canVote,
              fillColor: Theme.of(context).primaryColor,
              label: option,
              cornerRadius: _rowHeight / 2,
              valueBuilder: () => MultiMeasurement(
                mainValue: Measurement(
                  unit: Unit.percent,
                  value: value.toDouble(),
                ),
              ).displayValue(context),
              onTap: _canVote
                  ? () {
                      setState(() => _canVote = false);
                      widget.onVote?.call();
                    }
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
