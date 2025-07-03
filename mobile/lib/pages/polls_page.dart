import 'package:adair_flutter_lib/app_config.dart';
import 'package:adair_flutter_lib/pages/scroll_page.dart';
import 'package:adair_flutter_lib/res/dimen.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/gen/anglerslog.pb.dart';
import 'package:mobile/model/gen/userpolls.pb.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mobile/res/style.dart';
import 'package:mobile/utils/page_utils.dart';
import 'package:mobile/widgets/button.dart';
import 'package:mobile/widgets/empty_list_placeholder.dart';
import 'package:mobile/widgets/widget.dart';
import 'package:quiver/strings.dart';

import '../utils/number_utils.dart';
import '../utils/protobuf_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/filled_row.dart';
import 'feedback_page.dart';

class PollsPage extends StatefulWidget {
  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  late Future<void> _fetchPollsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPollsFuture = PollManager.get.fetchPolls();
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
            return PollManager.get.hasPoll
                ? _buildPolls()
                : _buildPlaceholder();
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
    if (!PollManager.get.hasFreePoll) {
      return const Empty();
    }

    return _PollWidget(
      titleText: Strings.of(context).pollsPageNextFreeFeature,
      successText: Strings.of(context).pollsPageThankYouFree,
      comingSoonTitleText: Strings.of(context).pollsPageComingSoonFree,
      poll: PollManager.get.polls!.free,
      canVote: PollManager.get.canVoteFree,
    );
  }

  Widget _buildProPoll() {
    if (!PollManager.get.hasProPoll) {
      return const Empty();
    }

    return _PollWidget(
      titleText: Strings.of(context).pollsPageNextProFeature,
      successText: Strings.of(context).pollsPageThankYouPro,
      comingSoonTitleText: Strings.of(context).pollsPageComingSoonPro,
      poll: PollManager.get.polls!.pro,
      canVote: PollManager.get.canVotePro,
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

class _PollWidget extends StatefulWidget {
  final String titleText;
  final String successText;
  final String comingSoonTitleText;
  final Poll poll;
  final bool canVote;

  const _PollWidget({
    required this.titleText,
    required this.successText,
    required this.comingSoonTitleText,
    required this.poll,
    required this.canVote,
  });

  @override
  State<_PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<_PollWidget> {
  static const _rowMaxValue = 100.0; // 100%.

  var _voteState = _VoteState.none;

  @override
  void initState() {
    super.initState();
    if (!widget.canVote) {
      _voteState = _VoteState.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    var totalVotes =
        _options.fold(0, (count, option) => count += option.voteCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titleText, style: styleListHeading(context)),
        const VerticalSpace(paddingDefault),
        ..._options.map((option) {
          var value =
              totalVotes > 0 ? percent(option.voteCount, totalVotes) : 0;

          return Padding(
            padding: option == _options.last ? insetsZero : insetsBottomSmall,
            child: FilledRow(
              maxValue: _rowMaxValue,
              value: value,
              showValue: _voteState == _VoteState.success,
              fillColor: AppConfig.get.colorAppTheme,
              label: _localization(option.localizations),
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
          widget.successText,
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
    if (_poll.comingSoon.isEmpty) {
      return const Empty();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VerticalSpace(paddingDefault),
        Text(
          widget.comingSoonTitleText,
          style: styleListHeading(context),
        ),
        const VerticalSpace(paddingSmall),
        Text(
          _localization(_poll.comingSoon),
          style: stylePrimary(context),
        ),
      ],
    );
  }

  Future<void> _vote(Option option) async {
    setState(() => _voteState = _VoteState.waiting);

    var didVote = await PollManager.get.vote(widget.poll, option);
    setState(() {
      if (didVote) {
        _voteState = _VoteState.success;
        option.voteCount += 1;
      } else {
        _voteState = _VoteState.fail;
      }
    });
  }

  bool get _canVote =>
      _voteState != _VoteState.success && _voteState != _VoteState.waiting;

  Poll get _poll => widget.poll;

  Iterable<Option> get _options => _poll.options;

  String _localization(Map<String, String> localizations) {
    var defaultLabel = localizations["en"];
    assert(
      isNotEmpty(defaultLabel),
      "An English (en) localization must exist for localizations: $localizations",
    );

    var locale = Localizations.localeOf(context);
    var languageCode = locale.languageCode;

    // Start with locale (en_CA), fallback on language (es), then finally on
    // English.
    return localizations[locale.toString()] ??
        localizations[languageCode] ??
        defaultLabel!;
  }
}
