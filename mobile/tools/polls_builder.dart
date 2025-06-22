/// Tool used for getting the latest user polls results, printing them to the
/// console, then optionally uploading a new poll to Firebase.
library;

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
        "en": "Add multiple species to a catch, and more backup options.",
        "es": "Agrega varias especies a una captura y más opciones de respaldo.",
      }.entries,
      options: [
        Option(
          voteCount: 0,
          localizations: {
            "en": "Add tide data to trips",
            "es": "Agrega datos de mareas a las salidas",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Import catches from friends",
            "es": "Importa capturas de tus amigos",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Allow manual coordinates input",
            "es": "Permitir ingreso manual de coordenadas",
          }.entries,
        ),
      ],
    ),
    pro: Poll(
      updatedAtTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
      comingSoon: {
        "en": "Customize catch list item subtitles.",
        "es": "Personaliza los subtítulos de los elementos de captura.",
      }.entries,
      options: [
        Option(
          voteCount: 0,
          localizations: {
            "en": "Save fishing licenses",
            "es": "Guardar licencias de pesca",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Select last values when adding catches",
            "es": "Seleccionar los últimos valores al agregar capturas",
          }.entries,
        ),
        Option(
          voteCount: 0,
          localizations: {
            "en": "Customize navigation menu ordering",
            "es": "Personalizar el orden del menú de navegación",
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
