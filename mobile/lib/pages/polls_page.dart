import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/pages/scroll_page.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/res/dimen.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/res/theme.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

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
    _fetchPollsFuture = _pollManager.fetchPolls();
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
        const VerticalSpace(paddingXL),
        _buildFreePoll(),
        const VerticalSpace(paddingXL),
        _buildProPoll(),
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
    if (_pollManager.freePoll == null) {
      return const Empty();
    }

    return _Poll(
      title: Strings.of(context).pollsPageNextFreeFeature,
      comingSoon: _pollManager.freePoll?.comingSoon,
      optionValues: _pollManager.freePoll?.optionValues ?? {},
      canVote: _pollManager.canVoteFree,
      type: PollType.free,
    );
  }

  Widget _buildProPoll() {
    if (_pollManager.proPoll == null) {
      return const Empty();
    }

    return _Poll(
      title: Strings.of(context).pollsPageNextProFeature,
      comingSoon: _pollManager.proPoll?.comingSoon,
      optionValues: _pollManager.proPoll?.optionValues ?? {},
      canVote: _pollManager.canVotePro,
      type: PollType.pro,
    );
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

enum _VoteState { none, waiting, success, fail }

class _Poll extends StatefulWidget {
  final String title;
  final String? comingSoon;
  final Map<String, int> optionValues;
  final bool canVote;
  final PollType type;

  const _Poll({
    required this.title,
    required this.comingSoon,
    required this.optionValues,
    required this.canVote,
    required this.type,
  });

  @override
  State<_Poll> createState() => _PollState();
}

class _PollState extends State<_Poll> {
  static const _rowHeight = 35.0;
  static const _rowMaxValue = 100.0; // 100%.

  late final Map<String, int> _optionValues;
  var _voteState = _VoteState.none;

  PollManager get _pollManager => PollManager.of(context);

  @override
  void initState() {
    super.initState();

    _optionValues = Map<String, int>.from(widget.optionValues);
    if (!widget.canVote) {
      _voteState = _VoteState.success;
    }
  }

  bool get _canVote =>
      _voteState != _VoteState.success && _voteState != _VoteState.waiting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: styleListHeading(context)),
        const VerticalSpace(paddingDefault),
        ..._optionValues.keys.map((option) {
          var total = _optionValues.values.toList().sum;
          var value =
              percent(_optionValues[option] ?? 0, total == 0 ? 1 : total);

          return Padding(
            padding: option == _optionValues.keys.last
                ? insetsZero
                : insetsBottomSmall,
            child: FilledRow(
              height: _rowHeight,
              maxValue: _rowMaxValue,
              value: value,
              showValue: _voteState == _VoteState.success,
              fillColor: context.colorDefault,
              label: option,
              cornerRadius: _rowHeight / 2,
              valueBuilder: () => MultiMeasurement(
                mainValue: Measurement(
                  unit: Unit.percent,
                  value: value.toDouble(),
                ),
              ).displayValue(context),
              onTap: _canVote ? () => _vote(option) : null,
            ),
          );
        }),
        _buildResultText(),
        _buildComingSoon(),
      ],
    );
  }

  Widget _buildResultText() {
    Widget child;
    switch (_voteState) {
      case _VoteState.none:
        child = const Empty();
        break;
      case _VoteState.waiting:
        child = const Loading();
        break;
      case _VoteState.success:
        child = Text(
          widget.type == PollType.free
              ? Strings.of(context).pollsPageThankYouFree
              : Strings.of(context).pollsPageThankYouPro,
          style: styleSuccess(context),
        );
        break;
      case _VoteState.fail:
        child = Text(
          Strings.of(context).pollsPageError,
          style: styleError(context),
        );
        break;
    }

    if (child is Empty) {
      return child;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalSpace(paddingDefault),
        child,
      ],
    );
  }

  Widget _buildComingSoon() {
    if (isEmpty(widget.comingSoon)) {
      return const Empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalSpace(paddingDefault),
        Text(
          widget.type == PollType.free
              ? Strings.of(context).pollsPageComingSoonFree
              : Strings.of(context).pollsPageComingSoonPro,
          style: styleListHeading(context),
        ),
        const VerticalSpace(paddingSmall),
        Text(
          widget.comingSoon!,
          style: stylePrimary(context),
        ),
      ],
    );
  }

  Future<void> _vote(String feature) async {
    setState(() => _voteState = _VoteState.waiting);

    var didVote = await _pollManager.vote(widget.type, feature);
    setState(() {
      if (didVote) {
        _voteState = _VoteState.success;
        _optionValues[feature] = _optionValues[feature]! + 1;
      } else {
        _voteState = _VoteState.fail;
      }
    });
  }
}
