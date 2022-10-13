import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/poll_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks/mocks.mocks.dart';
import 'mocks/stubbed_app_manager.dart';
import 'test_utils.dart';

void main() {
  late StubbedAppManager appManager;
  late PollManager pollManager;

  Future<void> stubPolls() async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("""{
      "free": {
        "options": {
          "Free Feature 1": 0,
          "Free Feature 2": 0,
          "Free Feature 3": 0
        },
        "updated_at_utc": 5000,
        "coming_soon": "Coming soon free"
      },
      "pro": {
        "options": {
          "Pro Feature 1": 0,
          "Pro Feature 2": 0,
          "Pro Feature 3": 0
        },
        "updated_at_utc": 5000,
        "coming_soon": "Coming soon pro"
      }
    }""");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await pollManager.initialize();
  }

  setUp(() {
    appManager = StubbedAppManager();

    when(appManager.propertiesManager.firebaseSecret).thenReturn("Secret");

    pollManager = PollManager(appManager.app);
  });

  test("canVoteFree false if no poll", () {
    expect(pollManager.canVoteFree, isFalse);
  });

  test("canVoteFree false if updatedAt < preferences", () async {
    when(appManager.userPreferenceManager.freePollVotedAt).thenReturn(10000);

    await stubPolls();
    expect(pollManager.canVoteFree, isFalse);
    verify(appManager.userPreferenceManager.freePollVotedAt).called(2);
  });

  test("canVoteFree true preferences is null", () async {
    when(appManager.userPreferenceManager.freePollVotedAt).thenReturn(null);

    await stubPolls();
    expect(pollManager.canVoteFree, isTrue);
    verify(appManager.userPreferenceManager.freePollVotedAt).called(1);
  });

  test("canVoteFree true if updatedAt > preferences", () async {
    when(appManager.userPreferenceManager.freePollVotedAt).thenReturn(1000);

    await stubPolls();
    expect(pollManager.canVoteFree, isTrue);
    verify(appManager.userPreferenceManager.freePollVotedAt).called(2);
  });

  test("canVotePro false if no poll", () {
    expect(pollManager.canVotePro, isFalse);
  });

  test("canVotePro false if updatedAt < preferences", () async {
    when(appManager.userPreferenceManager.proPollVotedAt).thenReturn(10000);

    await stubPolls();
    expect(pollManager.canVotePro, isFalse);
    verify(appManager.userPreferenceManager.proPollVotedAt).called(2);
  });

  test("canVotePro true preferences is null", () async {
    when(appManager.userPreferenceManager.proPollVotedAt).thenReturn(null);

    await stubPolls();
    expect(pollManager.canVotePro, isTrue);
    verify(appManager.userPreferenceManager.proPollVotedAt).called(1);
  });

  test("canVotePro true if updatedAt > preferences", () async {
    when(appManager.userPreferenceManager.proPollVotedAt).thenReturn(1000);

    await stubPolls();
    expect(pollManager.canVotePro, isTrue);
    verify(appManager.userPreferenceManager.proPollVotedAt).called(2);
  });

  test("fetchPolls handles bad JSON", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.badGateway);
    when(response.body).thenReturn("Test");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await pollManager.initialize();

    expect(pollManager.freePoll, isNull);
    expect(pollManager.proPoll, isNull);
    expect(pollManager.canVoteFree, isFalse);
    expect(pollManager.canVotePro, isFalse);
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
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await pollManager.initialize();

    expect(pollManager.freePoll, isNull);
    expect(pollManager.proPoll, isNull);
    expect(pollManager.canVoteFree, isFalse);
    expect(pollManager.canVotePro, isFalse);
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
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));
    await pollManager.initialize();

    expect(pollManager.freePoll, isNull);
    expect(pollManager.proPoll, isNull);
    expect(pollManager.canVoteFree, isFalse);
    expect(pollManager.canVotePro, isFalse);
  });

  test("fetchPolls with valid polls", () async {
    await stubPolls();

    var freePoll = pollManager.freePoll;
    expect(freePoll, isNotNull);
    expect(freePoll!.type, PollType.free);
    expect(freePoll.updatedAt, 5000);
    expect(freePoll.optionValues.length, 3);
    expect(freePoll.optionValues, {
      "Free Feature 1": 0,
      "Free Feature 2": 0,
      "Free Feature 3": 0,
    });

    var proPoll = pollManager.proPoll;
    expect(proPoll, isNotNull);
    expect(proPoll!.type, PollType.pro);
    expect(proPoll.updatedAt, 5000);
    expect(proPoll.optionValues.length, 3);
    expect(proPoll.optionValues, {
      "Pro Feature 1": 0,
      "Pro Feature 2": 0,
      "Pro Feature 3": 0,
    });
  });

  test("vote with unknown PollType", () async {
    expect(await pollManager.vote(PollType.unknown, "No Feature"), isFalse);
    verifyNever(appManager.httpWrapper.get(any));
  });

  test("vote with invalid response body", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("Not a number");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    expect(await pollManager.vote(PollType.free, "No Feature"), isFalse);
    verify(appManager.httpWrapper.get(any)).called(1);
    verifyNever(appManager.httpWrapper.put(any, body: anyNamed("body")));
  });

  test("vote fails at PUT call", () async {
    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.badGateway);
    when(putResponse.body).thenReturn("");
    when(appManager.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(await pollManager.vote(PollType.free, "No Feature"), isFalse);
    verify(appManager.httpWrapper.get(any)).called(1);
    verify(appManager.httpWrapper.put(any, body: anyNamed("body"))).called(1);
  });

  test("vote updates free preferences", () async {
    when(appManager.timeManager.currentDateTime).thenReturn(now());

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.ok);
    when(putResponse.body).thenReturn("");
    when(appManager.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(await pollManager.vote(PollType.free, "No Feature"), true);
    verify(appManager.userPreferenceManager.setFreePollVotedAt(any)).called(1);
    verifyNever(appManager.userPreferenceManager.setProPollVotedAt(any));
  });

  test("vote updates pro preferences", () async {
    when(appManager.timeManager.currentDateTime).thenReturn(now());

    var response = MockResponse();
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.body).thenReturn("10");
    when(appManager.httpWrapper.get(any))
        .thenAnswer((_) => Future.value(response));

    var putResponse = MockResponse();
    when(putResponse.statusCode).thenReturn(HttpStatus.ok);
    when(putResponse.body).thenReturn("");
    when(appManager.httpWrapper.put(any, body: anyNamed("body")))
        .thenAnswer((_) => Future.value(putResponse));

    expect(await pollManager.vote(PollType.pro, "No Feature"), true);
    verify(appManager.userPreferenceManager.setProPollVotedAt(any)).called(1);
    verifyNever(appManager.userPreferenceManager.setFreePollVotedAt(any));
  });
}
