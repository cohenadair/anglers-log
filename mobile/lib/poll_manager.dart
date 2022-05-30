import 'package:flutter/material.dart';
import 'package:mobile/user_preference_manager.dart';
import 'package:mobile/wrappers/http_wrapper.dart';
import 'package:provider/provider.dart';

import 'app_manager.dart';
import 'log.dart';
import 'properties_manager.dart';
import 'utils/network_utils.dart';

class PollManager {
  static PollManager of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).pollManager;

  static const _log = Log("PollManager");
  static const _url = "anglers-log.firebaseio.com";
  static const _path = "/polls.json";

  final AppManager _appManager;

  Poll? freePoll;
  Poll? proPoll;

  PollManager(this._appManager);

  HttpWrapper get _httpWrapper => _appManager.httpWrapper;

  PropertiesManager get _propertiesManager => _appManager.propertiesManager;

  UserPreferenceManager get _userPreferenceManager =>
      _appManager.userPreferenceManager;

  bool get canVoteFree => freePoll != null &&
      (_userPreferenceManager.freePollVotedAt == null ||
          _userPreferenceManager.freePollVotedAt! < freePoll!.updatedAt);

  bool get canVotePro => proPoll != null &&
      (_userPreferenceManager.proPollVotedAt == null ||
          _userPreferenceManager.proPollVotedAt! < proPoll!.updatedAt);

  Future<void> initialize() async {
    await fetch();
  }

  Future<void> fetch() async {
    var json = await getRestJson(
      _httpWrapper,
      Uri.https(_url, _path, {
        "auth": _propertiesManager.firebaseSecret,
        "timeout": "5s",
      }),
    );
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

        var options = <String, int>{};
        for (var option in json[jsonPoll]["options"].keys) {
          options[option] = json[jsonPoll]["options"][option];
        }

        var poll = Poll(
          type: type,
          updatedAt: json[jsonPoll]["updated_at_utc"],
          optionValues: options,
        );

        if (type == PollType.free) {
          freePoll = poll;
        } else if (type == PollType.pro) {
          proPoll = poll;
        } else {
          _log.e(StackTrace.current, "Unknown poll type: $type");
        }
      }
    } catch (error) {
      _log.e(StackTrace.current, "Error parsing poll JSON: $error, raw: $json");
    }
  }
}

enum PollType { unknown, free, pro }

class Poll {
  final PollType type;
  final Map<String, int> optionValues;
  final int updatedAt;

  Poll({
    required this.type,
    required this.optionValues,
    required this.updatedAt,
  });

  @override
  String toString() => "Poll {\n"
      "  type: $type,\n"
      "  optionValues: $optionValues,\n"
      "  updatedAt: $updatedAt,\n"
      "}";
}
