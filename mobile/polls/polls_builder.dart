import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:mobile/model/gen/userpolls.pb.dart';
import 'package:http/http.dart';

// ignore_for_file: avoid_print

void main() async {
  await _fetchCurrentPollResults();
  await _updatePolls();
}

// TODO: Replace secret with sensitive.properties
const _firebaseSecret = "";
const _authority = "anglers-log.firebaseio.com";
const _pollsRoot = "/polls-localized.json";

final _rootUri = Uri.https(_authority, _pollsRoot, {
  "auth": _firebaseSecret,
});

Future<void> _fetchCurrentPollResults() async {
  print("Fetching current poll results...");
  var polls = Polls()
    ..mergeFromProto3Json(jsonDecode((await get(_rootUri)).body));
  _printPollResults(polls.free, "Free");
  _printPollResults(polls.pro, "Pro");
}

void _printPollResults(Poll poll, String name) {
  print("$name:");

  var totalVotes = 0;
  for (var option in poll.options) {
    print("  - ${option.localizations["en"]}: ${option.voteCount}");
    totalVotes += option.voteCount;
  }
  print("  - Total votes: $totalVotes");
  print("");
}

Future<void> _updatePolls() async {
  print("Generating new polls...");

  var polls = Polls(
    free: Poll(
      updatedAtTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      comingSoon: {
        "en": "Coming soon free (English)",
        "en_US": "Coming soon free (English, US)",
        "es": "Coming soon free (Spanish)",
      }.entries,
      options: [
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 1 free (English)",
            "es": "Option 1 free (Spanish)",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 2 free (English)",
            "es": "Option 2 free (Spanish)",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 3 free (English)",
            "es": "Option 3 free (Spanish)",
          }.entries,
        ),
      ],
    ),
    pro: Poll(
      updatedAtTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      comingSoon: {
        "en": "Coming soon pro (English)",
        "es": "Coming soon pro (Spanish)",
      }.entries,
      options: [
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 1 pro (English)",
            "es": "Option 1 pro (Spanish)",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 2 pro (English)",
            "es": "Option 2 pro (Spanish)",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Option 3 pro (English)",
            "es": "Option 3 pro (Spanish)",
          }.entries,
        ),
      ],
    ),
  );

  // Maybe upload to Firebase.
  print(
      "WARNING: Uploading will replace all content at $_pollsRoot and cannot be undone.");
  stdout.write("Upload to Firebase? (y/n): ");
  if (stdin.readLineSync() == "y") {
    print("Uploading...");
    await put(_rootUri, body: jsonEncode(polls.toProto3Json()));
    print("Done!");
  }
}
