import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/time_manager.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';
import 'utils/string_utils.dart';
import 'utils/void_stream_controller.dart';

class PollManager {
  static PollManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).pollManager;

  static const _log = Log("PollManager");
  static const _url = "anglers-log.firebaseio.com";
  static const _root = "polls";
  static const _pathPolls = "/$_root.json";
  static const _pathValue = "/$_root/%s/options/%s.json";

  final _controller = VoidStreamController();
  final AppManager _appManager;

  Poll? freePoll;
  Poll? proPoll;

  PollManager(this._appManager);

  HttpWrapper get _httpWrapper => _appManager.httpWrapper;

  PropertiesManager get _propertiesManager => _appManager.propertiesManager;

  TimeManager get _timeManager => _appManager.timeManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  Stream<void> get stream => _controller.stream;

  bool get canVote => canVoteFree || canVotePro;

  bool get canVoteFree =>
      freePoll != null &&
      (_userPreferenceManager.freePollVotedAt == null ||
          _userPreferenceManager.freePollVotedAt! < freePoll!.updatedAt);

  bool get canVotePro =>
      proPoll != null &&
      (_userPreferenceManager.proPollVotedAt == null ||
          _userPreferenceManager.proPollVotedAt! < proPoll!.updatedAt);

  Future<void> initialize() async {
    await fetchPolls();
  }

  Future<void> fetchPolls() async {
    var json = await getRestJson(_httpWrapper, _uri(_pathPolls));
    if (json == null) {
      return;
    }

    try {
      freePoll = null;
      proPoll = null;

      for (var jsonPoll in json.keys) {
        var type = PollType.unknown;
        if (jsonPoll == "free") {
          type = PollType.free;
        } else if (jsonPoll == "pro") {
          type = PollType.pro;
        }

        if (type == PollType.unknown) {
          _log.e(StackTrace.current, "Unknown poll type: $type");
          continue;
        }

        var options = <String, int>{};
        for (var option in json[jsonPoll]["options"].keys) {
          options[option] = json[jsonPoll]["options"][option];
        }

        var poll = Poll(
          type: type,
          updatedAt: json[jsonPoll]["updated_at_utc"],
          optionValues: options,
          comingSoon: json[jsonPoll]["coming_soon"],
        );

        if (type == PollType.free) {
          freePoll = poll;
        } else if (type == PollType.pro) {
          proPoll = poll;
        }
      }
    } catch (error) {
      _log.e(StackTrace.current, "Error parsing poll JSON: $error, raw: $json");
    }
  }

  Future<bool> vote(PollType type, String feature) async {
    var result = await _vote(type, feature);
    _controller.notify();
    return result;
  }

  Future<bool> _vote(PollType type, String feature) async {
    if (type == PollType.unknown) {
      _log.e(StackTrace.current, "Unknown poll type while voting");
      return false;
    }

    var uri = _uri(format(_pathValue, [type.name, feature]));
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
        _timeManager.currentDateTime.toUtc().millisecondsSinceEpoch;
    switch (type) {
      case PollType.free:
        _userPreferenceManager.setFreePollVotedAt(currentEpoch);
        break;
      case PollType.pro:
        _userPreferenceManager.setProPollVotedAt(currentEpoch);
        break;
      case PollType.unknown:
        // Can't happen; checked at the beginning of this method.
        break;
    }

    return true;
  }

  Uri _uri(String path) {
    return Uri.https(_url, path, {
      "auth": _propertiesManager.firebaseSecret,
      "timeout": "5s",
    });
  }
}

enum PollType { unknown, free, pro }

class Poll {
  final PollType type;
  final Map<String, int> optionValues;
  final int updatedAt;
  final String? comingSoon;

  Poll({
    required this.type,
    required this.optionValues,
    required this.updatedAt,
    required this.comingSoon,
  });

  @override
  String toString() => "Poll {\n"
      "  type: $type,\n"
      "  optionValues: $optionValues,\n"
      "  updatedAt: $updatedAt,\n"
      "  comingSoon: $comingSoon,\n"
      "}";
}
