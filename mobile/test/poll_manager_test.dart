import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/model/gen/user_polls.pb.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_managers.dart';
import 'test_utils.dart';

void main() {
  late StubbedManagers managers;

  Polls defaultPolls() {
    return Polls(
      free: Poll(
        updatedAtTimestamp: Int64(5000),
        comingSoon: {
          "en": "Coming soon free",
        }.entries,
        options: {
          Option(
            voteCount: 0,
            localizations: {
              "en": "Free Feature 1",
            }.entries,
          ),
          Option(
            voteCount: 0,
            localizations: {
              "en": "Free Feature 2",
            }.entries,
          ),
          Option(
            voteCount: 0,
            localizations: {
              "en": "Free Feature 3",
            }.entries,
          ),
        },
      ),
      pro: Poll(
        updatedAtTimestamp: Int64(5000),
        comingSoon: {
          "en": "Coming soon pro",
        }.entries,
        options: {
          Option(
            voteCount: 0,
            localizations: {
              "en": "Pro Feature 1",
            }.entries,
          ),
          Option(
            voteCount: 0,
            localizations: {
              "en": "Pro Feature 2",
            }.entries,
          ),
          Option(
            voteCount: 0,
            localizations: {
              "en": "Pro Feature 3",
            }.entries,
          ),
        },
      ),
    );
  }

  Future<void> stubPolls([Polls? inputPolls]) async {
    var polls = inputPolls ?? defaultPolls();
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn(jsonEncode(polls.toProto3Json()));
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await PollManager.get.initialize();
  }

  setUp(() async {
    managers = await StubbedManagers.create();

    when(managers.propertiesManager.firebaseSecret).thenReturn("Secret");

    PollManager.reset();
  });

  test("canVote true for free poll only", () async {
    when(managers.userPreferenceManager.freePollVotedAt).thenReturn(null);

    await stubPolls(Polls(
      free: Poll(),
    ));
    expect(PollManager.get.canVote, isTrue);
  });

  test("canVote true for pro poll only", () async {
    when(managers.userPreferenceManager.proPollVotedAt).thenReturn(null);

    await stubPolls(Polls(pro: Poll()));
    expect(PollManager.get.canVote, isTrue);
  });

  test("hasPoll false for no polls", () async {
    expect(PollManager.get.hasPoll, isFalse);

    await stubPolls(Polls());
    expect(PollManager.get.hasPoll, isFalse);
  });

  test("hasPoll true for free", () async {
    await stubPolls(Polls(free: Poll()));
    expect(PollManager.get.hasPoll, isTrue);
  });

  test("hasPoll true for pro", () async {
    await stubPolls(Polls(pro: Poll()));
    expect(PollManager.get.hasPoll, isTrue);
  });

  test("canVoteFree false if no poll", () {
    expect(PollManager.get.canVoteFree, isFalse);
  });

  test("canVoteFree false if updatedAt < preferences", () async {
    when(managers.userPreferenceManager.freePollVotedAt).thenReturn(10000);

    await stubPolls();
    expect(PollManager.get.canVoteFree, isFalse);
    verify(managers.userPreferenceManager.freePollVotedAt).called(2);
  });

  test("canVoteFree true preferences is null", () async {
    when(managers.userPreferenceManager.freePollVotedAt).thenReturn(null);

    await stubPolls();
    expect(PollManager.get.canVoteFree, isTrue);
    verify(managers.userPreferenceManager.freePollVotedAt).called(1);
  });

  test("canVoteFree true if updatedAt > preferences", () async {
    when(managers.userPreferenceManager.freePollVotedAt).thenReturn(1000);

    await stubPolls();
    expect(PollManager.get.canVoteFree, isTrue);
    verify(managers.userPreferenceManager.freePollVotedAt).called(2);
  });

  test("canVotePro false if no poll", () {
    expect(PollManager.get.canVotePro, isFalse);
  });

  test("canVotePro false if updatedAt < preferences", () async {
    when(managers.userPreferenceManager.proPollVotedAt).thenReturn(10000);

    await stubPolls();
    expect(PollManager.get.canVotePro, isFalse);
    verify(managers.userPreferenceManager.proPollVotedAt).called(2);
  });

  test("canVotePro true preferences is null", () async {
    when(managers.userPreferenceManager.proPollVotedAt).thenReturn(null);

    await stubPolls();
    expect(PollManager.get.canVotePro, isTrue);
    verify(managers.userPreferenceManager.proPollVotedAt).called(1);
  });

  test("canVotePro true if updatedAt > preferences", () async {
    when(managers.userPreferenceManager.proPollVotedAt).thenReturn(1000);

    await stubPolls();
    expect(PollManager.get.canVotePro, isTrue);
    verify(managers.userPreferenceManager.proPollVotedAt).called(2);
  });

  test("fetchPolls handles bad JSON", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn("Test");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await PollManager.get.initialize();

    expect(PollManager.get.polls, isNull);
    expect(PollManager.get.canVoteFree, isFalse);
    expect(PollManager.get.canVotePro, isFalse);
  });

  test("fetchPolls unknown PollType", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("""{
      "bad-key": {
        "options": {
          "Free Feature 1": 0,
          "Free Feature 2": 0,
          "Free Feature 3": 0
        },
        "updated_at_utc": 5000
      }
    }""");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await PollManager.get.initialize();

    expect(PollManager.get.polls, isNull);
    expect(PollManager.get.canVoteFree, isFalse);
    expect(PollManager.get.canVotePro, isFalse);
  });

  test("fetchPolls JSON parse error", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("""{
      "free": {
        "options-bad": {
          "Free Feature 1": 0,
          "Free Feature 2": 0,
          "Free Feature 3": 0
        },
        "updated_at_utc": 5000
      }
    }""");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await PollManager.get.initialize();

    expect(PollManager.get.polls, isNull);
    expect(PollManager.get.canVoteFree, isFalse);
    expect(PollManager.get.canVotePro, isFalse);
  });

  test("fetchPolls with valid polls", () async {
    await stubPolls();

    var freePoll = PollManager.get.polls!.free;
    expect(freePoll, isNotNull);
    expect(freePoll.updatedAtTimestamp.toInt(), 5000);
    expect(freePoll.options.length, 3);
    expect(freePoll.options[0].voteCount, 0);
    expect(freePoll.options[0].localizations["en"], "Free Feature 1");
    expect(freePoll.options[1].voteCount, 0);
    expect(freePoll.options[1].localizations["en"], "Free Feature 2");
    expect(freePoll.options[2].voteCount, 0);
    expect(freePoll.options[2].localizations["en"], "Free Feature 3");

    var proPoll = PollManager.get.polls!.pro;
    expect(proPoll, isNotNull);
    expect(proPoll.updatedAtTimestamp.toInt(), 5000);
    expect(proPoll.options.length, 3);
    expect(proPoll.options[0].voteCount, 0);
    expect(proPoll.options[0].localizations["en"], "Pro Feature 1");
    expect(proPoll.options[1].voteCount, 0);
    expect(proPoll.options[1].localizations["en"], "Pro Feature 2");
    expect(proPoll.options[2].voteCount, 0);
    expect(proPoll.options[2].localizations["en"], "Pro Feature 3");
  });

  test("vote notifies listeners", () async {
    PollManager.get.stream.listen(expectAsync1((_) {}));
    expect(await PollManager.get.vote(Poll(), Option()), isFalse);
  });

  test("vote with invalid option", () async {
    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    expect(
      await PollManager.get.vote(PollManager.get.polls!.pro, Option()),
      isFalse,
    );
  });

  test("vote with invalid poll", () async {
    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    var option = Option();
    expect(
      await PollManager.get.vote(Poll(options: [option]), Option()),
      isFalse,
    );
  });

  test("vote with invalid response body", () async {
    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("Not a number");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    expect(
      await PollManager.get.vote(
          PollManager.get.polls!.pro, PollManager.get.polls!.pro.options.first),
      isFalse,
    );
    verify(managers.httpWrapper.get(any)).called(1);
    verifyNever(managers.httpWrapper.put(any, body: anyNamed("body")));
  });

  test("vote fails at PUT call", () async {
    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.badGateway);
    when(putResponse.body).thenReturn("");
    when(managers.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(
      await PollManager.get.vote(
          PollManager.get.polls!.pro, PollManager.get.polls!.pro.options.first),
      isFalse,
    );
    verify(managers.httpWrapper.get(any)).called(1);
    verify(managers.httpWrapper.put(any, body: anyNamed("body"))).called(1);
  });

  test("vote updates free preferences", () async {
    when(managers.lib.timeManager.currentDateTime).thenReturn(now());

    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.ok);
    when(putResponse.body).thenReturn("");
    when(managers.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(
      await PollManager.get.vote(PollManager.get.polls!.free,
          PollManager.get.polls!.free.options.first),
      isTrue,
    );
    verify(managers.userPreferenceManager.setFreePollVotedAt(any)).called(1);
    verifyNever(managers.userPreferenceManager.setProPollVotedAt(any));
  });

  test("vote updates pro preferences", () async {
    when(managers.lib.timeManager.currentDateTime).thenReturn(now());

    await stubPolls();
    verify(managers.httpWrapper.get(any)).called(1);

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(managers.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.ok);
    when(putResponse.body).thenReturn("");
    when(managers.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(
      await PollManager.get.vote(
          PollManager.get.polls!.pro, PollManager.get.polls!.pro.options.first),
      isTrue,
    );
    verify(managers.userPreferenceManager.setProPollVotedAt(any)).called(1);
    verifyNever(managers.userPreferenceManager.setFreePollVotedAt(any));
  });
}
