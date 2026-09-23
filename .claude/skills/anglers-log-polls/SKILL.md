---
name: anglers-log-polls
description: Fetches the current Anglers' Log in-app user poll (feature vote) results, optionally saves them to `anglers-log/poll-results.html`, and replaces the Free/Pro polls with new ones — always saving and verifying the current results first, and always getting the user's sign-off before publishing. Use when the user says things like "get the poll results", "how are the polls doing", "save the poll results", "update the polls", "new feature poll", "change the poll options", or "what's winning the feature vote" for Anglers' Log.
---

# Anglers' Log polls

The in-app polls live in the Firebase Realtime Database at
`anglers-log.firebaseio.com/polls-localized` as a `Polls` proto
(`anglers-log/mobile/protobuf/user_polls.proto`). There are two polls, `free`
and `pro`. Each has localized options with vote counts, a localized "coming
soon" string, and an `updatedAtTimestamp`. The app
(`anglers-log/mobile/lib/poll_manager.dart`) lets a user vote again when a
poll's `updatedAtTimestamp` is newer than their last vote.

All reads and writes go through `anglers-log/mobile/tools/polls_builder.dart`.
Run it from `anglers-log/mobile`. It reads the database secret
(`firebase.secret`) from `mobile/assets/sensitive.properties`. If that file is
missing, stop and tell the user.

```
dart run tools/polls_builder.dart fetch [--save]
dart run tools/polls_builder.dart update --input <file> [--remove <free|pro>] [--yes]
```

## Results page

`anglers-log/poll-results.html` is the permanent archive of every poll's
results. It's a dark-themed page with one collapsible section per saved set
of results, newest first and open. Its raw data is in the page's `poll-data`
JSON block. `fetch --save` adds the live results to that data and regenerates
the whole page from it. Never edit the page by hand, and never regenerate
it by any other means. If its look needs to change, edit the renderer in
`polls_builder.dart` and run `fetch --save`. Also, `fetch --save` does nothing
when the live results are identical to the newest saved ones.

Decide from the request which mode to run: **Results** or **Update**. "Update
the polls" always means Update mode, which includes Results mode's save step.

## Results mode

1. Run `fetch`. Add `--save` if the user asked to save the results.
2. Show the results as a table per poll: option (English), votes, share of
   total votes, plus the total and the "coming soon" text. Call out the
   leading option in each poll.
3. If you saved, give the page path as a link.

## Update mode

**Never upload before the current results are saved and verified, and never
upload without the user's explicit sign-off.** The script enforces the first
part: `update` fetches the live polls and aborts unless the newest results in
`poll-results.html` match them exactly. Don't work around a mismatch. Save
again instead (step 1).

1. **Save.** Run `fetch --save`.
2. **Verify the results with the user.** Show the saved results as in Results
   mode, since they're the final numbers for the polls being replaced. Ask the
   user to confirm they look right before going further. Stop here until they
   do.
3. **Gather the new polls.** Ask the user, if they haven't said:
   - Which polls to replace: Free, Pro, or both. A poll left out of the input
     is carried over unchanged, keeping its votes and timestamp. Use
     `--remove free|pro` only if the user explicitly wants a poll gone.
   - The options for each replaced poll, in English.
   - The "coming soon" text for each replaced poll. This is usually the
     winner of the previous poll, so suggest it from the results.
4. **Translate.** Every option and "coming soon" string needs an `en` value
   (the app asserts on it) plus a real translation for every other language
   the app supports. Find those languages from the
   `anglers-log/mobile/lib/l10n/localizations_*.arb` files. Use language codes
   only (e.g. `en`, `es`). `en_GB`/`en_US` are spelling variants, so skip them
   unless a string's spelling differs. Match the tone and length of existing
   translations; the newest entry in the page's `poll-data` block has them.
5. **Write the input** to the session scratchpad as proto3 JSON. Leave out
   `voteCount` and `updatedAtTimestamp`; the script resets votes to 0 and sets
   the timestamp to now for every poll in the input.

   ```json
   {
     "free": {
       "comingSoon": { "en": "…", "es": "…" },
       "options": [
         { "localizations": { "en": "…", "es": "…" } }
       ]
     }
   }
   ```

6. **Dry run.** Run `update --input <input>` without `--yes`. It verifies the
   saved results and prints the new polls.
7. **Verify the update with the user.** Show the full new polls, including
   every translation, and state which polls are replaced, carried over, or
   removed. Uploading replaces everything at `/polls-localized` and resets
   votes for the replaced polls. Wait for an explicit "yes" in chat for this
   specific upload. A yes to an earlier question, or in an earlier session,
   doesn't count.
8. **Upload.** Re-run the same command with `--yes`. If the saved-results
   check fails because votes came in after step 1, go back to step 1. Show the
   user the new final numbers, and get their "yes" again before retrying. The
   script re-fetches after uploading and checks the live data matches.
9. **Report** the new live polls. The next `fetch --save` adds them to the
   results page once they have votes.

## Notes

- The script uses `DateTime.now()` rather than `TimeManager` on purpose. It's
  a plain Dart CLI, and `TimeManager` depends on Flutter.
- There is a small window between the saved-results check and the upload. A
  vote cast in that window is lost. That's acceptable; don't add locking.
- Results from before the proto format (2022–2025) were migrated from the old
  `anglers-log/polls/` directory. They have English text only and are dated by
  the git commit that added them.
