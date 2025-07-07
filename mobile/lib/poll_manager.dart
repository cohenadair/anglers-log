import 'dart:async';

import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';

import 'app_manager.dart';
import 'log.dart';
import 'model/gen/user_polls.pb.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';
import 'utils/string_utils.dart';
import 'utils/void_stream_controller.dart';

class PollManager {
  static var _instance = PollManager._();

  static PollManager get get => _instance;

  @visibleForTesting
  static void set(PollManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = PollManager._();

  PollManager._();

  static const _log = Log("PollManager");
  static const _url = "anglers-log.firebaseio.com";
  static const _root = "polls-localized";
  static const _pathPolls = "/$_root.json";
  static const _pathValue = "/$_root/%s/options/%s/voteCount.json";

  final _controller = VoidStreamController();

  Polls? polls;

  HttpWrapper get _httpWrapper => AppManager.get.httpWrapper;

  Stream<void> get stream => _controller.stream;

  bool get canVote => canVoteFree || canVotePro;

  bool get canVoteFree =>
      hasFreePoll &&
      (UserPreferenceManager.get.freePollVotedAt == null ||
          UserPreferenceManager.get.freePollVotedAt! <
              polls!.free.updatedAtTimestamp.toInt());

  bool get canVotePro =>
      hasProPoll &&
      (UserPreferenceManager.get.proPollVotedAt == null ||
          UserPreferenceManager.get.proPollVotedAt! <
              polls!.pro.updatedAtTimestamp.toInt());

  bool get hasFreePoll => polls != null && polls!.hasFree();

  bool get hasProPoll => polls != null && polls!.hasPro();

  bool get hasPoll => hasFreePoll || hasProPoll;

  Future<void> initialize() async {
    await fetchPolls();
  }

  Future<void> fetchPolls() async {
    var json = await getRestJson(_httpWrapper, _uri(_pathPolls));
    if (json == null) {
      return;
    }

    try {
      polls = Polls()..mergeFromProto3Json(json);
    } catch (error) {
      _log.e(StackTrace.current, "Error parsing poll JSON: $error, raw: $json");
    }
  }

  Future<bool> vote(Poll poll, Option option) async {
    var result = await _vote(poll, option);
    _controller.notify();
    return result;
  }

  Future<bool> _vote(Poll poll, Option option) async {
    var optionIndex = poll.options.indexOf(option);
    if (optionIndex < 0) {
      _log.e(
        StackTrace.current,
        "Voted option ($option) doesn't exist in poll ($poll)",
      );
      return false;
    }

    String pollName;
    if (hasFreePoll && polls!.free == poll) {
      pollName = "free";
    } else if (hasProPoll && polls!.pro == poll) {
      pollName = "pro";
    } else {
      _log.e(StackTrace.current, "Voted poll doesn't exist");
      return false;
    }

    var uri = _uri(format(_pathValue, [pollName, optionIndex]));
    var response = await getRest(_httpWrapper, uri);

    var value = int.tryParse(response?.body ?? "");
    if (value == null) {
      return false;
    }

    // Increment existing value by 1. It's technically possible for votes to
    // get lost if multiple people are voting at the exact same time. For now,
    // let's not worry about it.
    if (await putRest(_httpWrapper, uri, (value + 1).toString()) == null) {
      return false;
    }

    var currentEpoch =
        TimeManager.get.currentDateTime.toUtc().millisecondsSinceEpoch;
    if (pollName == "free") {
      UserPreferenceManager.get.setFreePollVotedAt(currentEpoch);
    } else {
      UserPreferenceManager.get.setProPollVotedAt(currentEpoch);
    }

    return true;
  }

  Uri _uri(String path) {
    return Uri.https(_url, path, {
      "auth": PropertiesManager.get.firebaseSecret,
      "timeout": "5s",
    });
  }
}
