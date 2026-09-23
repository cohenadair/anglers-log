/// Tool for fetching the current in-app user poll results, saving them to
/// `anglers-log/poll-results.html`, and replacing the polls with new ones.
///
/// Run from `anglers-log/mobile`:
///
///   dart run tools/polls_builder.dart fetch [--save]
///   dart run tools/polls_builder.dart update --input <file>
///       [--remove <free|pro>] [--yes]
///
/// `fetch` prints the current results. With `--save`, they're appended to
/// the results page, unless they're identical to the newest saved results.
/// The page's raw data lives in its `poll-data` JSON block, and the rest of
/// the page is regenerated from it on every save; don't edit it by hand.
///
/// `update` refuses to do anything unless the newest saved results exactly
/// match the polls currently in Firebase, so poll data is never lost.
/// `--input` is a Polls proto3 JSON file. Every poll in it has its vote counts reset to 0
/// and its `updatedAtTimestamp` set to now. Polls missing from the input are
/// carried over unchanged, unless named by `--remove`. Without `--yes`, it's
/// a dry run that prints what would be uploaded.
library;

import 'dart:convert';
import 'dart:io';

import 'package:fixnum/fixnum.dart';
import 'package:http/http.dart';
import 'package:mobile/model/gen/user_polls.pb.dart';

// ignore_for_file: avoid_print

const _authority = "anglers-log.firebaseio.com";
const _pollsRoot = "/polls-localized.json";
const _secretKey = "firebase.secret";
const _pollNames = ["free", "pro"];

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _fail(_usage);
  }

  switch (args.first) {
    case "fetch":
      await _fetch(args.skip(1).toList());
    case "update":
      await _update(args.skip(1).toList());
    default:
      _fail(_usage);
  }
}

const _usage = """
Usage:
  dart run tools/polls_builder.dart fetch [--save]
  dart run tools/polls_builder.dart update --input <file> [--remove <free|pro>] [--yes]""";

Future<void> _fetch(List<String> args) async {
  print("Fetching current poll results...");
  final json = await _fetchJson();
  _printPolls(json);

  if (!args.contains("--save")) {
    return;
  }

  final entries = _readResults();
  if (entries.isNotEmpty && _encode(entries.first["polls"]) == _encode(json)) {
    print("Already saved as the newest results: ${_resultsFile.path}");
    return;
  }

  _writeResults([
    {"savedAt": DateTime.now().millisecondsSinceEpoch, "polls": json},
    ...entries,
  ]);
  print("Saved: ${_resultsFile.path}");
}

Future<void> _update(List<String> args) async {
  final inputPath = _option(args, "--input");
  final remove = _options(args, "--remove");
  final confirmed = args.contains("--yes");

  if (inputPath == null) {
    _fail(_usage);
  }

  for (final name in remove) {
    if (!_pollNames.contains(name)) {
      _fail("Invalid --remove value \"$name\"; must be one of $_pollNames.");
    }
  }

  // Verify the newest saved results match what's live before touching
  // anything.
  print("Verifying saved results against current Firebase polls...");
  final current = await _fetchJson();
  final entries = _readResults();
  if (entries.isEmpty || _encode(entries.first["polls"]) != _encode(current)) {
    _fail(
      "The newest results in ${_resultsFile.path} don't match the current "
      "polls in Firebase (votes may have been cast since they were saved). "
      "Run `fetch --save` again and retry. Nothing was uploaded.",
    );
  }
  print("Saved results verified: ${_resultsFile.path}");

  final polls = _buildPolls(
    current: Polls()..mergeFromProto3Json(current),
    input: Polls()
      ..mergeFromProto3Json(jsonDecode(File(inputPath).readAsStringSync())),
    remove: remove,
  );
  final newJson = polls.toProto3Json() as Map<String, dynamic>;

  print("");
  print("New polls:");
  _printPolls(newJson);

  if (!confirmed) {
    print("Dry run; nothing was uploaded. Re-run with --yes to upload.");
    return;
  }

  print("Uploading (replaces all content at $_pollsRoot)...");
  final response = await put(_rootUri(), body: jsonEncode(newJson));
  if (response.statusCode != HttpStatus.ok) {
    _fail("Upload failed (${response.statusCode}): ${response.body}");
  }

  // Confirm what's live now matches what was uploaded.
  if (_encode(await _fetchJson()) != _encode(newJson)) {
    _fail("Upload succeeded, but the live polls don't match the upload.");
  }
  print("Done! Live polls verified.");
}

Polls _buildPolls({
  required Polls current,
  required Polls input,
  required List<String> remove,
}) {
  final now = Int64(DateTime.now().millisecondsSinceEpoch);
  final polls = Polls();

  Poll? resolve(
    String name,
    Poll inputPoll,
    bool inputHas,
    Poll currentPoll,
    bool currentHas,
  ) {
    if (remove.contains(name)) {
      return null;
    }
    if (!inputHas) {
      return currentHas ? currentPoll : null;
    }
    _validatePoll(name, inputPoll);
    // voteCount must be explicitly written as 0; the app reads the value
    // before incrementing it, and a missing value makes votes fail.
    for (final option in inputPoll.options) {
      option.voteCount = 0;
    }
    return inputPoll..updatedAtTimestamp = now;
  }

  final free = resolve(
    "free",
    input.free,
    input.hasFree(),
    current.free,
    current.hasFree(),
  );
  if (free != null) {
    polls.free = free;
  }

  final pro = resolve(
    "pro",
    input.pro,
    input.hasPro(),
    current.pro,
    current.hasPro(),
  );
  if (pro != null) {
    polls.pro = pro;
  }

  return polls;
}

void _validatePoll(String name, Poll poll) {
  if (poll.options.isEmpty) {
    _fail("The $name poll has no options.");
  }
  // The app asserts an "en" localization exists for every string it shows.
  if (poll.comingSoon.isNotEmpty && !poll.comingSoon.containsKey("en")) {
    _fail("The $name poll's comingSoon is missing an \"en\" localization.");
  }
  for (final option in poll.options) {
    if (!option.localizations.containsKey("en")) {
      _fail("A $name poll option is missing an \"en\" localization: $option");
    }
  }
}

Future<Map<String, dynamic>> _fetchJson() async {
  final response = await get(_rootUri());
  if (response.statusCode != HttpStatus.ok) {
    _fail("Fetch failed (${response.statusCode}): ${response.body}");
  }

  // An empty database node returns "null".
  final json = jsonDecode(response.body);
  return json == null ? {} : json as Map<String, dynamic>;
}

void _printPolls(Map<String, dynamic> json) {
  final polls = Polls()..mergeFromProto3Json(json);
  if (polls.hasFree()) {
    _printPoll(polls.free, "Free");
  }
  if (polls.hasPro()) {
    _printPoll(polls.pro, "Pro");
  }
  if (!polls.hasFree() && !polls.hasPro()) {
    print("No polls.");
  }
}

void _printPoll(Poll poll, String name) {
  final updatedAt = DateTime.fromMillisecondsSinceEpoch(
    poll.updatedAtTimestamp.toInt(),
  );
  print("$name (updated $updatedAt):");

  var totalVotes = 0;
  for (final option in poll.options) {
    print("  - ${option.localizations["en"]}: ${option.voteCount}");
    totalVotes += option.voteCount;
  }
  print("  - Total votes: $totalVotes");
  if (poll.comingSoon.isNotEmpty) {
    print("  Coming soon: ${poll.comingSoon["en"]}");
  }
  print("");
}

File get _resultsFile =>
    File.fromUri(Platform.script.resolve("../../poll-results.html"));

final _dataPattern = RegExp(
  r'<script type="application/json" id="poll-data">(.*?)</script>',
  dotAll: true,
);

/// Returns the saved results, newest first. Each entry is
/// `{"savedAt": <epoch ms>, "polls": <Polls proto3 JSON>}`.
List<Map<String, dynamic>> _readResults() {
  final file = _resultsFile;
  if (!file.existsSync()) {
    return [];
  }

  final match = _dataPattern.firstMatch(file.readAsStringSync());
  if (match == null) {
    _fail("No poll-data block found in ${file.path}; not touching it.");
  }
  return (jsonDecode(match.group(1)!) as List).cast<Map<String, dynamic>>();
}

void _writeResults(List<Map<String, dynamic>> entries) {
  // Escape "</" so poll text can't close the data <script> early.
  final data = const JsonEncoder.withIndent(
    "  ",
  ).convert(entries).replaceAll("</", r"<\/");
  _resultsFile.writeAsStringSync(
    _renderResults(entries).replaceFirst(
      "%DATA%",
      '<script type="application/json" id="poll-data">\n$data\n</script>',
    ),
  );
}

String _renderResults(List<Map<String, dynamic>> entries) {
  final sections = StringBuffer();
  for (var i = 0; i < entries.length; i++) {
    sections.write(_renderEntry(entries[i], isNewest: i == 0));
  }

  final updated = entries.isEmpty
      ? ""
      : " · Last saved ${_formatDate(entries.first["savedAt"] as int)}";

  return """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<!-- Generated by mobile/tools/polls_builder.dart. Don't edit by hand; the
     page is rebuilt from the poll-data block on every save. -->
<title>Anglers' Log Poll Results</title>
<style>
$_css
</style>
</head>
<body>
<main>
<header>
  <h1>Anglers' Log poll results</h1>
  <p class="subtitle">${entries.length} saved results$updated</p>
</header>
$sections</main>
%DATA%
</body>
</html>
""";
}

String _renderEntry(Map<String, dynamic> entry, {required bool isNewest}) {
  final polls = Polls()
    ..mergeFromProto3Json(entry["polls"], ignoreUnknownFields: true);
  final named = [
    if (polls.hasFree()) ("Free", polls.free),
    if (polls.hasPro()) ("Pro", polls.pro),
  ];

  final leaders = named
      .map((poll) {
        final leader = _leader(poll.$2);
        return leader == null
            ? null
            : "<span><b>${poll.$1}:</b> ${_escape(_en(leader.localizations))}"
                  "</span>";
      })
      .whereType<String>()
      .join("");

  final totalVotes = named.fold(0, (sum, poll) => sum + _totalVotes(poll.$2));
  final badge = isNewest ? '<span class="badge">Latest</span>' : "";

  return """
<details class="entry"${isNewest ? " open" : ""}>
  <summary>
    <div class="summary-main">
      <div class="summary-title">Saved ${_formatDate(entry["savedAt"] as int)}$badge</div>
      <div class="summary-leaders">$leaders</div>
    </div>
    <div class="summary-total"><b>${_formatNumber(totalVotes)}</b> votes</div>
    <svg class="chevron" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 10l5 5 5-5"/></svg>
  </summary>
  <div class="polls">
${named.map((poll) => _renderPoll(poll.$1, poll.$2)).join()}  </div>
</details>
""";
}

String _renderPoll(String name, Poll poll) {
  final total = _totalVotes(poll);
  final leaderVotes = _leader(poll)?.voteCount;

  final options = StringBuffer();
  for (final option in poll.options) {
    final percent = total == 0 ? 0.0 : option.voteCount / total * 100;
    final isLeader = total > 0 && option.voteCount == leaderVotes;
    options.write("""
      <li class="option${isLeader ? " leader" : ""}">
        <div class="option-row">
          <span class="option-name">${_escape(_en(option.localizations))}</span>
          <span class="option-votes">${_formatNumber(option.voteCount)} <span class="percent">${percent.toStringAsFixed(1)}%</span></span>
        </div>
        <div class="bar"><div class="fill" style="width: ${percent.toStringAsFixed(1)}%"></div></div>
      </li>
""");
  }

  final comingSoon = poll.comingSoon.isEmpty
      ? ""
      : """
    <div class="coming-soon">
      <div class="label">Coming soon</div>
      <p>${_escape(_en(poll.comingSoon))}</p>
    </div>
""";

  return """
  <section class="poll">
    <div class="poll-header">
      <h2>$name</h2>
      <span class="poll-meta">Started ${_formatDate(poll.updatedAtTimestamp.toInt())} · ${_formatNumber(total)} votes</span>
    </div>
    <ul class="options">
$options    </ul>
$comingSoon  </section>
""";
}

Option? _leader(Poll poll) {
  if (poll.options.isEmpty || _totalVotes(poll) == 0) {
    return null;
  }
  return poll.options.reduce(
    (leader, option) => option.voteCount > leader.voteCount ? option : leader,
  );
}

int _totalVotes(Poll poll) =>
    poll.options.fold(0, (sum, option) => sum + option.voteCount);

String _en(Map<String, String> localizations) =>
    localizations["en"] ?? localizations.values.firstOrNull ?? "";

String _escape(String text) => text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");

String _formatNumber(int value) => value.toString().replaceAllMapped(
  RegExp(r"\B(?=(\d{3})+(?!\d))"),
  (_) => ",",
);

String _formatDate(int epochMs) {
  const months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", //
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  return "${months[date.month - 1]} ${date.day}, ${date.year}";
}

/// Dark theme matching the app's dark mode, with its light blue accent.
const _css = """
:root {
  color-scheme: dark;
  --bg: #121212;
  --surface: #1e1e1e;
  --surface-2: #262626;
  --border: rgba(255, 255, 255, 0.10);
  --text: #ffffff;
  --text-2: rgba(255, 255, 255, 0.70);
  --text-3: rgba(255, 255, 255, 0.45);
  --accent: #03a9f4;
  --accent-soft: rgba(3, 169, 244, 0.16);
  --track: rgba(255, 255, 255, 0.08);
  --fill: rgba(255, 255, 255, 0.28);
}
* { box-sizing: border-box; }
body {
  margin: 0;
  background: var(--bg);
  color: var(--text);
  font: 15px/1.5 Roboto, system-ui, -apple-system, "Segoe UI", sans-serif;
  -webkit-font-smoothing: antialiased;
}
main { max-width: 820px; margin: 0 auto; padding: 40px 16px 64px; }
header { margin-bottom: 24px; padding-left: 14px; border-left: 4px solid var(--accent); }
h1 { margin: 0; font-size: 26px; font-weight: 700; }
.subtitle { margin: 4px 0 0; color: var(--text-2); }
.entry {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 12px;
  margin-bottom: 12px;
  overflow: hidden;
}
summary {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  cursor: pointer;
  list-style: none;
}
summary::-webkit-details-marker { display: none; }
summary:hover { background: rgba(255, 255, 255, 0.03); }
summary:focus-visible { outline: 2px solid var(--accent); outline-offset: -2px; }
.summary-main { flex: 1; min-width: 0; }
.summary-title { font-weight: 500; font-size: 16px; display: flex; align-items: center; gap: 8px; }
.summary-leaders { color: var(--text-2); font-size: 13px; display: flex; flex-wrap: wrap; gap: 2px 16px; margin-top: 2px; }
.summary-leaders b { color: var(--text-3); font-weight: 500; }
.summary-total { color: var(--text-2); font-size: 13px; white-space: nowrap; }
.summary-total b { color: var(--text); font-weight: 500; font-variant-numeric: tabular-nums; }
.badge {
  background: var(--accent);
  color: #000;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  padding: 1px 8px;
  border-radius: 999px;
}
.chevron {
  width: 22px;
  height: 22px;
  flex: none;
  fill: none;
  stroke: var(--text-3);
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  transition: transform 0.15s ease;
}
.entry[open] .chevron { transform: rotate(180deg); }
.polls {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 12px;
  padding: 0 16px 16px;
}
.poll { background: var(--surface-2); border-radius: 10px; padding: 16px; }
.poll-header { display: flex; align-items: baseline; justify-content: space-between; gap: 8px; flex-wrap: wrap; }
h2 { margin: 0; font-size: 17px; font-weight: 700; color: var(--accent); }
.poll-meta { color: var(--text-3); font-size: 12px; }
.options { list-style: none; margin: 12px 0 0; padding: 0; display: grid; gap: 12px; }
.option-row { display: flex; justify-content: space-between; gap: 12px; font-size: 14px; }
.option-name { color: var(--text-2); }
.option-votes { white-space: nowrap; font-variant-numeric: tabular-nums; }
.percent { color: var(--text-3); margin-left: 4px; }
.leader .option-name { color: var(--text); font-weight: 500; }
.bar { height: 6px; background: var(--track); border-radius: 3px; margin-top: 6px; overflow: hidden; }
.fill { height: 100%; background: var(--fill); border-radius: 3px; }
.leader .fill { background: var(--accent); }
.coming-soon {
  margin-top: 16px;
  padding: 10px 12px;
  background: var(--accent-soft);
  border-radius: 8px;
}
.coming-soon .label {
  color: var(--accent);
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.04em;
  text-transform: uppercase;
}
.coming-soon p { margin: 2px 0 0; font-size: 13px; color: var(--text-2); white-space: pre-line; }
@media (max-width: 520px) {
  summary { flex-wrap: wrap; }
  .summary-total { order: 3; width: 100%; padding-left: 0; }
  .polls { grid-template-columns: 1fr; }
}
""";

/// Canonical, key-sorted encoding so JSON can be compared regardless of the
/// key order Firebase returns.
String _encode(dynamic json) =>
    const JsonEncoder.withIndent("  ").convert(_sortKeys(json));

dynamic _sortKeys(dynamic json) {
  if (json is Map) {
    final keys = json.keys.map((key) => key.toString()).toList()..sort();
    return {for (final key in keys) key: _sortKeys(json[key])};
  }
  if (json is List) {
    return json.map(_sortKeys).toList();
  }
  return json;
}

Uri _rootUri() =>
    Uri.https(_authority, _pollsRoot, {"auth": _firebaseSecret()});

String _firebaseSecret() {
  final file = File.fromUri(
    Platform.script.resolve("../assets/sensitive.properties"),
  );
  if (!file.existsSync()) {
    _fail("Missing ${file.path}; it's needed for \"$_secretKey\".");
  }

  for (final line in file.readAsLinesSync()) {
    final index = line.indexOf("=");
    if (index > 0 && line.substring(0, index).trim() == _secretKey) {
      return line.substring(index + 1).trim();
    }
  }
  _fail("\"$_secretKey\" not found in ${file.path}.");
}

String? _option(List<String> args, String name) {
  final values = _options(args, name);
  return values.isEmpty ? null : values.last;
}

List<String> _options(List<String> args, String name) {
  final result = <String>[];
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == name) {
      result.add(args[i + 1]);
    }
  }
  return result;
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
